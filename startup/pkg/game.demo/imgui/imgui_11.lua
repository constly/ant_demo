local ecs = ...
local ImGui  = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_11_system",
    category        = mgr.type_imgui,
    name            = "11_蓝图示例",
    file            = "imgui/imgui_11.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local ed = require "imgui.node_editor"
local ImGuiExtend = require "imgui.extend"

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("蓝图编辑器使用演示")
		ImGui.Text("开发中...")
	end
	ImGui.End()
end