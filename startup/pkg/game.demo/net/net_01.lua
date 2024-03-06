local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "net_01_system",
    category        = mgr.type_net,
    name            = "01_局域网广播",
    file            = "net/net_01.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)
local ImGui     = require "imgui"
local ltask 	= require "ltask"
local run_type
local session = 0
local port = 17668
local last_error
local idx = 1
local send_msg = "hello, i'm lan server, idx = " ..idx
local recv_msg = nil


function system.on_entry()
	
end 

function system.on_leave()
	run_type = nil 
	session = 0
	recv_msg = nil
	last_error = nil
end 

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("本示例演示如何在局域网中广播/接收消息, 一般用于局域网战斗房间发现")
		ImGui.Text("本示例正常运行需要开启多个客户端, 具体操作请看 README.md") 
		ImGui.SetCursorPos(50, 100) 
		ImGui.BeginGroup()
		if not run_type then
			if ImGui.ButtonEx("广播消息", 120, 60) then 
				run_type = 1
				system.create_server()
			end
			ImGui.SameLine()
			if ImGui.ButtonEx("接收消息", 120, 60) then 
				run_type = 2
				system.create_client()
			end
		elseif run_type == 1 then 
			if last_error == 0 then 
				ImGui.Text("程序正在局域网中广播以下消息:")
				ImGui.Text(send_msg) 
				ImGui.SameLine()
				if ImGui.Button(" Add ") then 
					idx = idx + 1
					send_msg = "hello, i'm lan server, idx = " .. idx
				end
			else 
				ImGui.Text("服务器广播失败, 错误码: " .. (last_error or "nil"))
			end
			if ImGui.ButtonEx(" 返 回 ") then 
				session = session + 1
				run_type = nil
			end 
		elseif run_type == 2 then 
			if recv_msg then 
				ImGui.Text("收到局域网消息:")
				ImGui.Text(recv_msg)
			else
				ImGui.Text("未收到任何消息, 错误码: " .. (last_error or "nil")) 
			end 
			if ImGui.ButtonEx(" 返 回 ") then 
				session = session + 1
				run_type = nil
			end 
		end 
		ImGui.EndGroup()
	end 
	ImGui.End()
end

function system.create_server()
	session = session + 1
	local _session = session
	-- 注意，这里的fork实际是启动一个协程，并不是新起了一个线程
	ltask.fork(function()
		local ly_net 	= require 'ly.net'
		local broadcast = ly_net.CreateBroadCast()
		print("create_server", broadcast:init_server("255.255.255.255", port), broadcast:last_error())
		while _session == session do 
			last_error = broadcast:send(send_msg) 
			if last_error ~= 0 then 
				last_error = broadcast:last_error()
			end
			ltask.sleep(50)
		end	
		broadcast:close()
		print("ltask end")
	end)
end 

function system.create_client()
	session = session + 1
	local _session = session
	-- 注意，这里的fork实际是启动一个协程，并不是新起了一个线程
	ltask.fork(function()
		local ly_net 	= require 'ly.net'
		local broadcast = ly_net.CreateBroadCast()
		print("create_client", broadcast:init_client(port), broadcast:last_error())
		while _session == session do 
			local ip, port, msg = broadcast:receive()
			if ip then 
				recv_msg = string.format("ip:  %s \nport: %d \nmsg: %s", ip, port, msg)
			else 
				last_error = broadcast:last_error()
				recv_msg = nil
			end
			ltask.sleep(50)
		end	
		broadcast:close()
		print("ltask end")
	end)
end