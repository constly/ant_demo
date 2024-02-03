local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_04_system",
    category        = mgr.type_core,
    name            = "04_luabind",
    file            = "core/core_04.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)