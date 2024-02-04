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
    if ImGui.Begin("window_body", ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("暂缓")
	end 
	ImGui.End()
end