local ecs = ...
local system = ecs.system "init_system"
local world = ecs.world
local w = world.w

---@type ly.common
local common = import_package 'ly.common' 	

local math3d = require "math3d"
local icamera = ecs.require "ant.camera|camera"
local window = require "window"
local ientity = ecs.require "ant.entity|entity"

---@type game_01.client
local client

local ientity = ecs.require "ant.entity|entity"

local pre 

function system.preinit()
	-- 设置项目根目录
	if world.args.ecs.project_root then
		common.path_def.set_project_root(world.args.ecs.project_root)
	end
	client = require 'client'.new(ecs)
end 


function system.init()
	window.set_title("Ant Game Engine 学习记录 - 2D游戏01")
	
	local font = import_package "ant.font"
	font.import "/pkg/demo.res/font/Alibaba-PuHuiTi-Regular.ttf"

	client.init()
end 

function system.exit()
	client.shutdown()
	client = nil
end

function system.init_world()
	pre = os.clock()
end

function system.data_changed()
	local cur = os.clock()
	local delta = cur - pre
	pre = cur
	client.update(delta)
end
