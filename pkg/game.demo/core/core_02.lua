local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_02_system",
    category        = mgr.type_core,
    name            = "02_entity&system",
    file            = "core/core_02.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		-- 演示如何创建/删除/遍历entity
		-- 演示system的禁用 和 激活
	end
	ImGui.End()
end