local ecs = ...
local system = ecs.system "init_system"
local world = ecs.world
local w = world.w

---@type ly.common
local common = import_package 'ly.common' 	

local math3d = require "math3d"
local icamera = ecs.require "ant.camera|camera"

---@type sims.client
local client
local timer = common.new_timer()

local pre

function system.preinit()
	-- 设置项目根目录
	if world.args.ecs.project_root then
		common.path_def.project_root = world.args.ecs.project_root
	end
	client = require 'client'.new(ecs)
	timer:add(1, function()
		print("exec timer1")
	end)
	timer:add(2, function()
		print("exec timer2")
	end)
	timer:add(3, function()
		print("exec timer3")
	end)
end 

function system.init()
	client.start()
end 

function system.exit()
	client.shutdown()
	client = nil
end

function system.init_world()
	print("system.init_world")	
	world:create_instance { prefab = "/pkg/demo.res/light_skybox.prefab" }

	local main_queue = w:first "main_queue camera_ref:in"
	local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
	local dir = math3d.vector(0, -1, 1)
	local size = 4
	local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
	local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
	icamera.focus_aabb(main_camera, aabb, dir)
end

function system.data_changed()
	timer:update()
	
	local cur = os.clock()
	if not pre then 
		pre = cur
	end

	local delta = cur - pre
	pre = os.clock()
	client.update(delta)
end
