local ecs = ...
local ImGui     = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_04_system",
    category        = mgr.type_imgui,
    name            = "04_Table",
    desc            = "尚未实现",
    file            = "imgui/imgui_04.lua"
}
local system = mgr.create_system(tbParam)

function system.data_changed()
    ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("暂缓")		
	end 
	ImGui.End()
end