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
local eitor 

function system.on_entry()
	if not eitor then 
		eitor = dep.chess_map.create({});
	end
end

function system.on_leave()
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		local size_x, size_y = ImGui.GetContentRegionAvail()
		--ImGui.BeginChild("##child", size_x - 5, size_y - 5, ImGui.ChildFlags({"Border"}))
		eitor.on_render(0.033)
		--ImGui.EndChild()	
	end 
	ImGui.End()
end