local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_02_system",
    category        = mgr.type_core,
    name            = "02_引擎源码学习",
    file            = "core/core_02.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)

local text = 
[[
一. engine/
	1. abc.lua 
	2. bcd.lua 

二. pkg/
	pkg.audio 
		1. 说明
	pkg.asset 
		2. 

	ant.timer
	ant.timeline 
]]

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text(text)
	end
	ImGui.End()
end