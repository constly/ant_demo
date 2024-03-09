--------------------------------------------------------------
--- 局域网房间数据
--------------------------------------------------------------

local room_list = require 'room_list' ---@type ly.room.match.room_list
local net = import_package "ant.net"
local ltask = require "ltask"
local seri = require "bee.serialization"
local protocol = require "protocol"
local port = 9843
--local ip = "127.0.0.1"
local ip = "192.168.1.4"
local room_name 
local room_type = 0; -- 1 or 2; 1-服务器房间; 2-客户端房间
local quit

local tb_members = {}  	---@type ly.room.match.member[]
local self_id;			--- 本地玩家
local need_exit
local next_id = 0;
local client_fd 

local function reset_data()
	tb_members = {}
	self_id = 0;
	room_type = 0;
	need_exit = nil
	client_fd = nil
	room_name = nil
	next_id = 0;
end

--------------------------------------------------------------
--- 成员管理
--------------------------------------------------------------
---@return ly.room.match.member 查找房间成员
local function add_member(fd, is_leader)
	next_id = next_id + 1;
	local tb = {} ---@type ly.room.match.member
	tb.id = next_id
	tb.name = "玩家" .. next_id
	tb.fd = fd
	tb.is_leader = is_leader
	table.insert(tb_members, tb)
	return tb;
end

local function remove_member(fd)
	for i, v in ipairs(tb_members) do 
		if v.fd == fd then 
			return table.remove(tb_members, i);
		end 
	end 
end

--------------------------------------------------------------
--- 协议注册与处理
--------------------------------------------------------------
local cmd = {list = {}}
-- 客户端协议
cmd.c2s_join_room = 101				-- 请求加入房间
cmd.c2s_exit_room = 102				-- 请求离开房间

-- 服务器协议
cmd.s2c_join_room_rsp = 201			-- 请求加入房间rsp
cmd.s2c_exit_room_rsp = 202			-- 请求离开房间rso

cmd.s2c_all_members = 251			-- 通知房间成员列表
cmd.s2c_kick = 252					-- 通知踢人
cmd.s2c_room_rename = 253			-- 通知房间改名
cmd.s2c_room_begin = 259			-- 通知房间开始

local function register(name, callback)
	cmd.list[name] = callback
end 

local function send_to_server(cmd, tbParam)
	local pack = string.pack("<s2", seri.packstring(cmd, tbParam))
	print("send_to_server", cmd, #pack)
	net.send(client_fd, pack)
end

local function send_to_client(fd, cmd, tbParam)
	if fd then 
		local pack = string.pack("<s2", seri.packstring(cmd, tbParam))
		print("send_to_client", cmd, #pack)
		net.send(fd, pack);
	end
end
 
local function notify_to_all_client(cmd, tbParam)
	for i, v in ipairs(tb_members) do 
		send_to_client(v.fd, cmd, tbParam)
	end
end

local function refresh_members()
	notify_to_all_client(cmd.s2c_all_members, tb_members)
end

local function init()
	-- 服务器执行
	register(cmd.c2s_join_room, function(fd, tbParam)
		local tb = add_member(fd, false)
		send_to_client(tb.fd, cmd.s2c_join_room_rsp, {ret = true, id = tb.id})
		refresh_members()
	end)
	register(cmd.c2s_exit_room, function(fd, tbParam)
		local tb = remove_member(fd)
		if tb then 
			send_to_client(tb.fd, cmd.s2c_exit_room_rsp, {ret = true})
			refresh_members()
		end
	end)

	-- 客户端执行
	register(cmd.s2c_join_room_rsp, function(tbParam)
		if tbParam.ret then 
			self_id = tbParam.id;
		else 
			need_exit = true;
		end
	end)
	register(cmd.s2c_exit_room_rsp, function(tbParam)
		if tbParam.ret then 
			need_exit = true
		end
	end)
	register(cmd.s2c_all_members, function(tbParam)
		tb_members = tbParam
		for i, v in ipairs(tb_members) do 
			v.is_self = v.id == self_id
		end
	end)
	register(cmd.s2c_kick, function(tbParam)
		if tbParam.role_id == self_id then 
			need_exit = true;
		end 
	end)
	register(cmd.s2c_room_rename, function(tbParam)
	end)
	register(cmd.s2c_room_begin, function(tbParam)
		print("cmd.s2c_room_begin")
	end)
end
init()

--------------------------------------------------------------
--- socket创建 与 协议收发
--------------------------------------------------------------
--- 房间服务器端
local function create_server()
	local session_id = 0;
	local sessions = {}
	local listen_fd, error = net.listen(ip, port) 
	if not listen_fd then 
		log.warn("failed to create room, error = ", error or "")
		return false
	end 

	print("create server ok, addr = ", string.format("%s:%s", ip, port))
	local close_session = function(s, notify)
		if s.fd then 
			net.close(s.fd)
			remove_member(s.fd)
			s.fd = nil
			if notify then
				refresh_members()
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
				local name, param = seri.unpack(msg)
				local callback = cmd.list[name]
				if callback then callback(client_fd, param) end
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
	return true;
end 

--- 房间客户端
local function create_client(ip, port)
	local ret, fd = net.connect(ip, tonumber(port))
	if not ret then 
		log.warn("faild to connect room, error is", fd)
		return false 
	end 

	--- 定时处理服务器消息
	print("create client ok, addr = ", string.format("%s:%s", ip, port))
	ltask.fork(function()
		local reading_queue = {}
		while not quit do 
			local reading, err = net.recv(fd)
			if reading == nil then 
				need_exit = true
				log.warn("服务器已关闭, recv error:", err)
				break 
			end 
			table.insert(reading_queue, reading)
			while true do
				local msg = protocol.readchunk(reading_queue)
				if msg == nil then break end
				local name, param = seri.unpack(msg)
				local callback = cmd.list[name]
				if callback then callback(param) end
			end
		end 
	end)
	client_fd = fd
	return true;
end


--------------------------------------------------------------
--- api 接口
--------------------------------------------------------------
local api = {}  ---@class ly.room.match.room_data
--- 初始化
function api.init()
	reset_data()
end 

--- 创建房间 - 服务器端执行
function api.create()
	quit = false
	if not create_server() then return end 
	room_type = 1
	local tb = add_member(nil, true)
	self_id = tb.id
	return true
end 

--- 战斗开始 
function api.begin()
	if not api.is_server() then return end 
	notify_to_all_client(cmd.s2c_room_begin, {features = {}})
end

--- 请求加入房间 - 客户端执行
function api.c2s_join(ip, port)
	quit = false
	if not create_client(ip, port) then return end 
	room_type = 2
	send_to_server(cmd.c2s_join_room, {})
	return true;
end 

--- 请求离开房间 - 客户端执行 
function api.c2s_apply_exit()
	send_to_server(cmd.c2s_exit_room, {})
end

--- 关闭房间
function api.close()
	print("close room")
	if room_type == 1 then 
		room_list.broadcast("close");
	end
	reset_data()
	quit = true
end 

--- 是否需要关闭房间
function api.need_exit()
	return need_exit
end 

--- 每帧更新
function api.tick()
	-- 如果是服务器房间，则向局域网内广播自身信息
	if room_type == 1 then 
		local msg = string.format("port:%d;name:%s", port, room_name or "")
		room_list.broadcast(msg);
	end
end 

--- 得到房间成员列表
function api.get_room_members()
	return tb_members
end 

--- 是不是服务器
function api.is_server()
	return room_type == 1
end 

return api