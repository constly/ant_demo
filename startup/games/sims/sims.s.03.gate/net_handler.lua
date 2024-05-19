local net = import_package "ant.net"
local seri = require "bee.serialization"
local protocol = require "protocol"
local ltask = require "ltask"

---@param gate sims.s.gate
local function new(gate)
	---@class sims.s.gate.net_handler
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
				player_mgr.notify_fd_close(s.fd)
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
	end

	function api.dispatch_rpc(client_fd, cmd, tbParam)
		local tb = msg.tb_rpc[cmd]
		if not tb then return end

		client_fd = client_fd or 0
		local p = player_mgr.find_by_fd(client_fd)
		if not p and cmd ~= msg.rpc_login then return end 

		local ret = tb.server(p, tbParam, client_fd)
		if ret and (not p or p.is_online) then 
			if client_fd > 0 then 
				local pack = string.pack("<s2", seri.packstring(1, cmd, ret))
				net.send(client_fd, pack);
			elseif client_fd == 0 then
				ltask.send(ServiceWindow, "exec_richman_client_rpc", cmd, ret)
			end 
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