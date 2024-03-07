local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "net_02_system",
    category        = mgr.type_net,
    name            = "02_socket",
    file            = "net/net_02.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)
local ImGui     = require "imgui"
local ltask 	= require "ltask"
local dep 		= require 'dep' ---@type game.demo.dep
local run_type
local order = 0
local ip = "127.0.0.1"
local port = 17667
local server_sessions = {}
local client_data = {}

function system.on_leave()
	server_sessions = {}
	order = 0
	run_type = nil
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("本示例演示网络socket的使用，注意:本Demo未处理socket粘包的问题")
		ImGui.Text("本示例正常运行需要开启多个客户端, 具体操作请看 README.md") 
		ImGui.SetCursorPos(50, 100) 
		ImGui.BeginGroup()
		if not run_type then
			if ImGui.ButtonEx("创建服务器", 120, 60) then 
				run_type = 1
				server_sessions = system.create_server()
			end
			ImGui.SameLine()
			if ImGui.ButtonEx("创建客户端", 120, 60) then 
				run_type = 2
				client_data = system.create_client()
			end
		elseif run_type == 1 then 
			ImGui.Text("服务器运行中, 共连接了 " .. #server_sessions .. " 个客户端:")
			for session, v in pairs(server_sessions) do 
				ImGui.Text(string.format("客户端%s, 收到消息:%s", session, v.recv_msg))
			end
			if ImGui.ButtonEx(" 返 回 ") then 
				order = order + 1
				run_type = nil
			end 
		elseif run_type == 2 then 
			if not client_data then 
				ImGui.Text(string.format("connect失败, server addr = %s:%d", ip, port))
			else 
				ImGui.Text("客户端运行中")
				ImGui.Text("发送数据: " .. (client_data.send_msg or ""))
				ImGui.Text("接收数据: " .. (client_data.recv_msg or ""))
			end
			if ImGui.ButtonEx(" 返 回 ") then 
				order = order + 1
				run_type = nil
			end 
		end 
		ImGui.EndGroup()
	end 
	ImGui.End()
end

function system.create_server()
	order = order + 1
	local _order = order
	local net = dep.net
	local session_id = 0;
	local sessions = {}
	local listen_fd = net.listen(ip, port) 
	local quit = false
	print("server listen", listen_fd, ip, port)

	local close_session = function(s)
		if s.fd then 
			net.close(s.fd)
			s.fd = nil
		end
	end

	local close_all_session = function()
		for _, s in pairs(sessions) do
			close_session(s)
		end
		net.close(listen_fd)
		quit = true;
	end

	local new_session = function(client_fd)
		session_id = session_id + 1
		local currrent_session = session_id
		local s = {
			fd = client_fd,
			session = session_id,
			data = "",
			recv_msg = "",
		}
		sessions[currrent_session] = s
		print("New client", currrent_session, client_fd)
		while not quit do 
			local reading = net.recv(client_fd)
			if reading == nil then break end

			local msg = s.data
			if msg == nil then break end
			msg = msg .. reading
			s.data = msg
		end 
		print("Close client", currrent_session)
		s.data = nil
		close_session(s)
		sessions[currrent_session] = nil
	end

	-- 监听客户端的新链接
	ltask.fork(function()
		while not quit do 
			local fd = net.accept(listen_fd)
			ltask.fork(new_session, fd)
		end
	end)

	-- 定时处理客户端的新消息
	ltask.fork(function()
		while not quit do 
			for session, s in pairs(sessions) do
				local data = s.data
				if data ~= "" then
					s.data = ""
					s.recv_msg = data
				end
			end
			ltask.sleep(10);
		end
	end)

	-- 定时往客户端发送消息
	ltask.fork(function()
		while not quit do 
			for i, s in pairs(sessions) do 
				if s.fd then 
					net.send(s.fd, "recv: " .. s.recv_msg)
				end 
			end
			ltask.sleep(10);
		end
	end)

	ltask.fork(function()
		while _order == order do 
			ltask.sleep(0)
		end
		close_all_session();		
	end)
	return sessions
end 

function system.create_client()
	order = order + 1
	local _order = order
	local net = dep.net
	local ret, fd = net.connect(ip, port)
	local cache = {}
	local idx = 0;
	if not ret then 
		return;
	end
	print("client connect", fd, ip, port)

	--- 定时处理服务器消息
	ltask.fork(function()
		while _order == order do 
			local content, err = net.recv(fd)
			cache.recv_msg = content
			if err then 
				print("recv error:", err)
				break 
			end
			ltask.sleep(10)
		end 
		print("end recv server msg.")
	end)

	--- 定时往服务器发数据
	ltask.fork(function()
		while _order == order do 
			idx = idx + 1
			cache.send_msg = "hello, my name is client, msg idx = " .. idx
			net.send(fd, cache.send_msg)
			ltask.sleep(10)
		end 
		net.close(fd)
	end)
	return cache
end