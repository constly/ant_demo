local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_03_system",
    category        = mgr.type_imgui,
    name            = "03_窗口",
    desc            = "尚未实现",
    file            = "imgui/imgui_03.lua"
}
local system = mgr.create_system(tbParam)

function system.data_changed()
    

end