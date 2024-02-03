local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_03_system",
    category        = mgr.type_core,
    name            = "03_luamake",
    file            = "core/core_03.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)