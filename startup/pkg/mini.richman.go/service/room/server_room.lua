--------------------------------------------------------------
--- 服务器房间
--------------------------------------------------------------
local net = import_package "ant.net"
---@type ly.room
local ly_room = import_package 'ly.room'
local room_list = ly_room.get_room_list()

local seri = require "bee.serialization"
local protocol = require "protocol"
local ltask = require "ltask"
local players = require 'service.room.server_players'  		---@type mrg.server_players
local msg = require '_core.msg' 							---@type mrg.msg
local api = {}												---@class mrg.server_room
local server_ip
local server_port
local server_ip_type
local room_name 
local room_state = 2  ---@type number 房间状态(1-匹配中;2-战斗中;3-战斗结束)
local listen_fd
local quit = false

msg.server = api

api.players = players

function api.dispatch_rpc(client_fd, cmd, tbParam)
	local tb = msg.tb_rpc[cmd]
	if not tb then return end

	local ret = tb.server(client_fd, tbParam)
	if ret then 
		if client_fd then 
			local pack = string.pack("<s2", seri.packstring(1, cmd, ret))
			net.send(client_fd, pack);
		else
			ltask.send(ServiceWindow, "exec_richman_client_rpc", cmd, ret)
		end 
	end 
end

function api.notify_to_all_client(cmd, tbParam)
	for i, v in ipairs(players.tb_members) do 
		api.send_to_client(v.fd, cmd, tbParam)
	end
end

function api.refresh_members()
	api.notify_to_all_client(msg.s2c_room_members, players.tb_members)
end

function api.test() 
	api.notify_to_all_client(msg.s2c_ping, {v = "1"})
end


--------------------------------------------------------------
--- api接口
--------------------------------------------------------------
--- 关闭服务器
function api.close()
	if listen_fd then 
		room_list.broadcast("close");
		room_list.exit()
		net.close(listen_fd)
		listen_fd = nil
	end
	quit = true
end

--- 服务器是否开启
function api.is_open()
	return listen_fd ~= nil
end

function api.send_to_client(fd, cmd, tbParam)
	if fd then 
		local pack = string.pack("<s2", seri.packstring(2, cmd, tbParam))
		net.send(fd, pack);
	else 
		local cb = msg.tb_s2c[cmd]
		if cb then 
			cb(tbParam)
		end
	end
end

--- 初始化服务器
function api.init_server(ip, port)
	players.reset()
	msg.init()
	quit = false
	server_ip = ip
	server_port = tonumber(port)
	server_ip_type = 'IPv4'
	local session_id = 0;
	local sessions = {}
	local error
	listen_fd, error = net.listen(server_ip, server_port) 
	if not listen_fd then 
		log.warn(string.format("failed to create room, addr = %s, error = %s", string.format("%s:%s", server_ip, port), error or ""))
		return false
	end 

	print("create server ok, addr = ", string.format("%s:%s", server_ip, port))
	local close_session = function(s, notify)
		if s.fd then 
			net.close(s.fd)
			players.remove_member(s.fd)
			s.fd = nil
			if notify then
				api.refresh_members()
			end
		end
	end

	local close_all_session = function()
		for _, s in pairs(sessions) do
			close_session(s)
		end
		net.close(listen_fd)
		print("[server] close all sessions")
	end

	-- 当有新客户端连接时
	local new_session = function(client_fd)
		session_id = session_id + 1
		local currrent_session = session_id
		local s = {
			fd = client_fd,
			session = session_id,
			reading = {},
		}
		sessions[currrent_session] = s
		print("New client", currrent_session, client_fd)
		while not quit do 
			local data = net.recv(client_fd)
			if data == nil then break end
			table.insert(s.reading, data)
			while true do
				local msg = protocol.readchunk(s.reading)
				if not msg then break end
				local cmd, tbParam = seri.unpack(msg)
				api.dispatch_rpc(client_fd, cmd, tbParam)
			end
		end 
		print("Close client", currrent_session)
		close_session(s, true)
		sessions[currrent_session] = nil
	end

	-- 监听客户端的新链接
	ltask.fork(function()
		while not quit do 
			local fd = net.accept(listen_fd)
			ltask.fork(new_session, fd)
		end
	end)
	ltask.fork(function()
		while not quit do
			ltask.sleep(0)
		end
		close_all_session();
	end)

	local tb = players.add_member(nil, true)
	tb.is_leader = true 
	tb.is_local = true
	return true;
end 

--- 每帧更新
function api.tick()
	if not server_ip then return end 
	-- 向局域网内广播自身信息
	local msg = string.format("port&%s;name&%s;ip&%s;type&%s;state&%d", server_port, room_name or "", server_ip, server_ip_type, room_state)
	room_list.broadcast(msg);
end 


return api