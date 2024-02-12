local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "rmlui_03_system",
    category        = mgr.type_rmlui,
    name            = "03_UI动画",
    file            = "rmlui/rmlui_03.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)


function system.data_changed()
	-- UI上挂特效
	-- UI上显示RT
end