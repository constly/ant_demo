local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_11_system",
    category        = mgr.type_core,
    name            = "11_待定",
    file            = "core/core_11.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w
