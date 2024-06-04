local ecs       = ...
local world     = ecs.world
local bgfx      = require "bgfx"
local math3d    = require "math3d"
local layoutmgr = require "layoutmgr"
local sampler   = require "sampler"
local platform  = require "bee.platform"
local OS        = platform.os

local utils		= require 'utils' ---@type test.bfgx.utils
local ROOT<const> = utils.Root

local is 		= ecs.system "init_system"
local ImGui 	= require "imgui"
local viewid = 2

function is:init()
    
end


local clicked = false;
function is:data_changed()
	ImGui.SetNextWindowPos(50, 200, ImGui.Cond.FirstUseEver)
	ImGui.SetNextWindowSize(300, 200, ImGui.Cond.FirstUseEver);

	local window_flag = ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"}
	if ImGui.Begin("window_body", nil, window_flag) then 
		ImGui.Text("hell world.")
		if ImGui.Button("test button") then 
			clicked = not clicked
		end
		if clicked then 
			ImGui.SameLine()
			ImGui.Text("click me")
		end
	end
	ImGui.End()
end


function is:update()
	bgfx.touch(viewid)	
	bgfx.set_debug("")
end