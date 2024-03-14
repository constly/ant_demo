local ecs = ...
local system 		= ecs.system "startup"
local dep 			= require 'client.dep'
local ImGui 		= dep.ImGui
local statemachine 	= require 'client.state_machine'  ---@type mini.richman.go.view.state_machine

local world = ecs.world
local w = world.w
local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"
local math3d = require "math3d"
local icamera = ecs.require "ant.camera|camera"

function system.init()
	print("system.init")
end 

function system.post_init()
	print("system.post_init")
end

function system.init_world()
	print("system.init_world")
	statemachine.init(false, RichmanMgr.is_listen_player)

	world:create_instance { prefab = "/pkg/game.res/light_skybox.prefab" }
	world:create_entity{
		policy = { "ant.render|simplerender", },
		data = {
			scene = { s = {250, 1, 250}, },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible	= true,
			mesh_result = imesh.init_mesh(ientity.plane_mesh(), true),
			owned_mesh_buffer = true,
			on_ready = function(e) 
				local main_queue = w:first "main_queue camera_ref:in"
				local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
				local dir = math3d.vector(0, -1, 1)
				local size = 40
				local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
				local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
				icamera.focus_aabb(main_camera, aabb, dir)
			end,
		}
	}
end

function system.exit()
	print("system.exit")
	statemachine.reset()
end


function system.data_changed()
	ImGui.SetNextWindowPos(10, 10)
	ImGui.SetNextWindowSize(100, 60);
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		if ImGui.ButtonEx(" 返 回 ") then 
			RichmanMgr.exitCB()
		end
	end 
	ImGui.End()
end