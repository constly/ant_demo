local ecs = ...
local dep = require "dep" ---@type demo.dep
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "designer_05_system",
    category        = mgr.type_designer,
    name            = "05_多语言编辑器",
    file            = "designer/designer_05.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)
local ImGui = dep.ImGui

---@type ly.game_editor.editor
local editor 

function system.on_entry()
	editor = require 'designer.editor'
end

function system.on_leave()
end

function system.data_changed()

end