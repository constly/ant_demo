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
	-- 这里为了避免初始化太卡，特意fork了一个子线程来执行
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
    if ImGui.Begin("window_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		ImGui.SetCursorPos(50, 50)
		ImGui.BeginGroup()
		ImGui.Text("1. 演示如何新建service\n2. service之间互相通信\n3. 暂停/继续service\n")
		if ImGui.Button("通 信", 80) then 
			ltask.send(service_01, "send_event", "test", "abc")
		end
		ImGui.EndGroup()
	end
	ImGui.End()
end
