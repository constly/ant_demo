local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_07_system",
    category        = mgr.type_imgui,
    name            = "07_撤销/回退",
    desc            = "尚未实现",
    file            = "imgui/imgui_07.lua"
}
local system = mgr.create_system(tbParam)

function system.data_changed()
    

end