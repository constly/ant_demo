local ecs = ...
local dep = require "dep" ---@type demo.dep
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "designer_03_system",
    category        = mgr.type_designer,
    name            = "03_ini编辑器",
    file            = "designer/designer_03.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local ImGui = dep.ImGui

---@type ly.game_editor.editor
local editor 

function system.on_entry()
	editor = require 'designer.editor'
	editor.browse_and_open("/pkg/demo.res/designer/ini/demo.ini")
end

function system.on_leave()
	editor.save()
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		editor.default_draw()
	end 
	ImGui.End()
end