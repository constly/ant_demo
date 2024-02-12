local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "rmlui_02_system",
    category        = mgr.type_rmlui,
    name            = "02_列表和弹框",
    file            = "rmlui/rmlui_02.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)


function system.data_changed()

end