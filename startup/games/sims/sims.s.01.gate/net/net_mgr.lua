local net = import_package "ant.net"
local seri = require "bee.serialization"
local protocol = require "protocol"
local ltask = require "ltask"

---@param gate sims.s.gate
local function new(gate)
	---@class sims.s.net_mgr
	local api = {}
	local listen_fd
	local quit = false

	function api.start(ip, port)
		local session_id = 0;
		local sessions = {}
		local error
		listen_fd, error = net.listen(ip, port) 
		if not listen_fd then 
			log.warn(string.format("failed to create gate server, addr = %s, error = %s", string.format("%s:%s", ip, port), error or ""))
			return false
		end 

		print("create gate server ok, addr = ", string.format("%s:%s", ip, port))
		local close_session = function(s, notify)
			if s.fd then 
				net.close(s.fd)
				gate.player_mgr.notify_fd_close(s.fd)
				if notify then
					ltask.send(gate.addrCenter, "notify_player_offline", s.fd)
				end
				s.fd = nil
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
	end

	function api.dispatch_rpc(client_fd, cmd, tbParam)
		local tb = gate.msg.tb_rpc[cmd]
		if not tb then 
			log.warn("can not find rpc =", cmd)
			return 
		end

		client_fd = client_fd or 0
		local p = gate.player_mgr.find_by_fd(client_fd)
		if tb.type == gate.msg.type_gate then
			if not p and cmd ~= gate.msg.rpc_login then return end 

			local ret = tb.server(p, tbParam, client_fd)
			if ret and (not p or p.is_online) then 
				api.dispatch_rpc_rsp(client_fd, cmd, ret)
			end 
		end 
		if not p then 
			return log.warn("消息转发失败，请先发登录协议, cmd == ", cmd)
		end

		if tb.type == gate.msg.type_center then 
			ltask.send(gate.addrCenter, "dispatch_rpc", client_fd, p.id, cmd, tbParam)
		end
	end

	function api.dispatch_rpc_rsp(client_fd, cmd, tbParam)
		if client_fd > 0 then 
			local pack = string.pack("<s2", seri.packstring(1, cmd, tbParam))
			net.send(client_fd, pack);
		elseif client_fd == 0 then
			ltask.send(gate.addrClient, "exec_sims_client_rpc", cmd, tbParam)
		end 
	end

	function api.send_to_client(fd, cmd, tbParam)
		fd = fd or 0
		if fd > 0 then 
			local pack = string.pack("<s2", seri.packstring(2, cmd, tbParam))
			net.send(fd, pack);
		elseif fd == 0 then 
			ltask.send(gate.addrClient, "exec_sims_client_s2c", cmd, tbParam)
		end
	end

	function api.close()
		if listen_fd then 
			net.close(listen_fd)
			listen_fd = nil
		end
		quit = true
	end

	return api
end

return {new = new}