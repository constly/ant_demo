local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_09_system",
    category        = mgr.type_imgui,
    name            = "09_自定义绘制",
    desc            = "尚未实现",
    file            = "imgui/imgui_09.lua"
}
local system = mgr.create_system(tbParam)

function system.data_changed()
    

end