local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "rmlui_02_system",
    category        = mgr.type_rmlui,
    name            = "02_template",
    file            = "rmlui/rmlui_02.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)
local iRmlUi = ecs.require "ant.rmlui|rmlui_system"
local ui

function system.on_entry()
    ui = iRmlUi.open ("rmlui_02", "/pkg/demo/rmlui/rmlui_02.html")
end

function system.on_leave()
	ui.close()
end