--------------------------------------------------------------
--- 客户端房间
--------------------------------------------------------------
local net 	= import_package "ant.net"
local seri 	= require "bee.serialization"
local protocol = require "protocol"
local ltask = require "ltask"

---@param client sims.client
local function new(client)
	---@class sims.client_room
	local api = {} 		
	local msg = client.msg
	local client_fd
	local quit = false

	--------------------------------------------------------------
	--- dispatch
	--------------------------------------------------------------
	local dispatch_rpc = function(cmd, tbParam)
		local tb = msg.tb_rpc[cmd]
		if tb then tb.client(tbParam) end
	end 

	local dispatch_s2c = function(cmd, tbParam)
		local cb = msg.tb_s2c[cmd]
		if cb then cb(tbParam) end
	end

	--------------------------------------------------------------
	--- api
	--------------------------------------------------------------
	--- 清空
	function api.close()
		if client_fd then 
			client.players.reset()
			net.close(client_fd)
			client_fd = nil
		end 
		quit = true;
	end 

	--- 是否开启
	function api.is_open()
		return client_fd ~= nil
	end

	--- 客户端 rpc 调用
	function api.call_rpc(cmd, tbParam)
		local pack = string.pack("<s2", seri.packstring(cmd, tbParam or {}))
		net.send(client_fd, pack)
	end

	function api.apply_login(guid) client.call_server(msg.rpc_login, {guid = guid}) end
	function api.apply_exit() client.call_server(msg.rpc_exit) end 
	function api.apply_begin() client.call_server(msg.rpc_room_begin) end

	--- 初始化客户端房间
	function api.init(ip, port)
		quit = false
		api.need_exit = false
		local ret, fd = net.connect(ip, tonumber(port))
		if not ret then 
			log.warn("faild to connect room, error is", fd)
			return false 
		end 
		--- 处理服务器消息
		print("create client ok, addr = ", string.format("%s:%s", ip, port))
		ltask.fork(function()
			local reading_queue = {}
			while not quit do 
				local reading, err = net.recv(fd)
				if reading == nil then 
					quit = true
					log.warn("服务器已关闭, recv error:", err)
					client.statemachine.goto_state(client.statemachine.state_entry)
					break 
				end 
				table.insert(reading_queue, reading)
				while true do
					local msg = protocol.readchunk(reading_queue)
					if msg == nil then break end
					local type, cmd, tbParam = seri.unpack(msg)
					if type == 1 then 
						dispatch_rpc(cmd, tbParam)
					elseif type == 2 then 
						dispatch_s2c(cmd, tbParam)
					end 
				end
			end 
			api.close()
		end)
		client_fd = fd
		return true;
	end

	return api
end

return {new = new}
