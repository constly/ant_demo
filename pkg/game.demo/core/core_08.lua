local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_08_system",
    category        = mgr.type_core,
    name            = "08_待定",
    file            = "core/core_08.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)


function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("待定")
	end 
	ImGui.End()
end