local ecs = ...
local dep = require "dep" ---@type game.demo.dep
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "designer_06_system",
    category        = mgr.type_designer,
    name            = "06_逻辑地图编辑",
    file            = "designer/designer_06.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local ImGui = dep.ImGui
---@type chess_editor
local editor 

function system.on_entry()
	if not editor then 
		editor = dep.chess_map.create({});
	end
end

function system.on_leave()
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		local size_x, size_y = ImGui.GetContentRegionAvail()
		size_x = size_x - 100
		size_y = size_y - 50
		ImGui.SetCursorPos(100, 30)
		ImGui.BeginChild("##child", size_x, size_y, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"})
			editor.on_render(0.033)	
		ImGui.EndChild()	
	end 
	ImGui.End()
end