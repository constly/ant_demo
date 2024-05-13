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

---@type sims.client
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
	client.start()
	window.set_title("Ant Game Engine 学习记录 - 局域网联机测试")
end 

function system.exit()
	client.shutdown()
	client = nil
end

function system.init_world()
	print("system.init_world")	
	world:create_instance { prefab = "/pkg/demo.res/light_skybox.prefab" }
	world:create_entity{
		policy = {
			"ant.render|simplerender",
		},
		data = {
			scene 		= {
				s = {1, 1, 1},
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible     = false,
			mesh_result	= ientity.plane_mesh(),
            owned_mesh_buffer = true,
		}
	}

	world:create_entity{
		policy = {
			"ant.render|simplerender",
		},
		data = {
			scene 		= {
				s = {1, 1, 1},
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible     = false,
			mesh_result	= ientity.plane_mesh(),
            owned_mesh_buffer = true,
		}
	}

	local main_queue = w:first "main_queue camera_ref:in"
	local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
	local dir = math3d.vector(0, -1, 1)
	local size = 4
	local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
	local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
	icamera.focus_aabb(main_camera, aabb, dir)

	pre = os.clock()
end

function system.data_changed()
	local cur = os.clock()
	local delta = cur - pre
	pre = cur
	client.update(delta)
end
