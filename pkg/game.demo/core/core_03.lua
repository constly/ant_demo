local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_03_system",
    category        = mgr.type_core,
    name            = "03_ltask",
    file            = "core/core_03.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)


local ltask    = require "ltask"
local service_01

-- 在主服务上扩展rpc接口，供其他服务使用
local S = ltask.dispatch()
function S.rpc_notify_core_03(msg)
	print("[rpc_notify_core_03]", msg)
end

function system.on_entry()
	-- 这里为了避免初始化太卡，特意fork了一个子线程执行
	if not service_01 then
		ltask.fork(function ()
			service_01 = ltask.uniqueservice("game.demo|service_01", ltask.self())
		end)
	else 
		ltask.send(service_01, "continue")
	end
end 

function system.on_leave()
	if service_01 then
		-- 服务退出后，目前没有找到再次创建的办法，所以此处调用暂停
		ltask.send(service_01, "pause")
		--ltask.send(service_01, "quit")
		--service_01 = nil
	end
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		ImGui.SetCursorPos(50, 50)
		ImGui.BeginGroup()
		ImGui.Text("1. 演示如何新建service\n2. service之间互相通信\n3. 暂停/继续service\n")
		if ImGui.Button("通 信", 80) then 
			ltask.send(service_01, "send_event", "test", "abc")
		end
		ImGui.EndGroup()

		ImGui.SetCursorPos(450, 50)
		ImGui.BeginGroup()
		ImGui.Text("注意:")
		ImGui.Text("Ant 引擎使用 ltask 来使用处理器的多核，并将功能模块分离到不同的服务中")
		ImGui.Text("这些服务各自处于独立的 Lua 虚拟机，被 ltask 调度到不同的线程运行")
		ImGui.Text("服务间通过消息通讯，而不能直接共享状态")
		ImGui.Text("\n即:")
		ImGui.Text("引擎内有多个服务")
		ImGui.Text("每个服务是一个虚拟机")
		ImGui.Text("一个虚拟机内可以有多个ecs world")
		ImGui.Text("一个虚拟机内多次require一个文件，会得到同一个table")
		ImGui.Text("ecs.require() 可以让文件在ecs间隔离")
		ImGui.Text("切换场景，会传入新的feature重新启动窗口服务，期间其他服务不受影响")
		ImGui.Text("应该是不太建议一个服务内有多个ecs world, 如果有这种需求可以新启一个服务来解决")
		ImGui.EndGroup()

	end
	ImGui.End()
end
