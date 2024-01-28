local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_10_system",
    category        = mgr.type_imgui,
    name            = "10_蓝图示例",
    file            = "imgui/imgui_10.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
        local draw_list = ImGui.draw_list;
		ImGui.Text("蓝图示例")
	end 
	ImGui.End()
end