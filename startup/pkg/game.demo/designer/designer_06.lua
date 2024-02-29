local ecs = ...
local dep = require "dep" ---@type game.demo.dep
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "designer_06_system",
    category        = mgr.type_designer,
    name            = "06_棋盘编辑器",
    file            = "designer/designer_06.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local ImGui = dep.ImGui

function system.on_entry()
end

function system.on_leave()
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.Text("test")
	end 
	ImGui.End()
end