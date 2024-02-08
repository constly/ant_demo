local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_11_system",
    category        = mgr.type_core,
    name            = "11_角色控制",
    file            = "core/core_11.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w
local icamera = ecs.require "ant.camera|camera"
local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.render|components.entity"
local math3d = require "math3d"
local PC  = ecs.require("utils.world_handler").proxy_creator()
local timer = ecs.require "ant.timer|timer_system"
local iom = ecs.require "ant.objcontroller|obj_motion"
local player
local kb_mb

function system.on_entry()
	PC:create_instance { prefab = "/pkg/game.res/light.prefab" }
	PC:create_entity{
		policy = { "ant.render|simplerender", },
		data = {
			scene = { s = {250, 1, 250}, },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible_state= "main_view",
			simplemesh 	= imesh.init_mesh(ientity.plane_mesh()),
			on_ready = function(e) end,
		}
	}

	PC:create_instance {
		prefab = "/pkg/game.res/npc/test_002/test_002.glb|mesh.prefab",
        on_ready = function (e)
			local entities = e.tag['*']
			player = entities[1]
			local main_queue = w:first "main_queue camera_ref:in"
            local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
            local dir = math3d.vector(0, -1, 1)
			icamera.focus_prefab(main_camera, entities, dir)
		end,
	}
	
	local iom   = ecs.require "ant.objcontroller|obj_motion"
	for i = 1, 3 do 
		PC:create_instance {
			prefab = "/pkg/ant.resources.binary/meshes/base/cube.glb|mesh.prefab",
			on_ready = function(e)
				local eid = e.tag['*'][1]
				local ee<close> = world:entity(eid, "scene:in")
				iom.set_position(ee, math3d.vector(i * 6 - 10, 1, 5))
			end
		}
	end

	kb_mb = world:sub{"keyboard"}
end 

function system.on_leave()
	PC:clear()
	world:unsub(kb_mb)
end


function system.data_changed()
	local move_dir = {x = 0, z = 0}
	local delta = timer.delta() * 0.001
	for _, key, press, status in kb_mb:unpack() do
		--print("data_changed", key, press, status)
        local pressed = press == 1 or press == 0
        if key == "D" then
            move_dir.x = move_dir.x + 1
		end
		if key == "A" then 
			move_dir.x = move_dir.x - 1
		end
		if key == "W" then 
			move_dir.z = move_dir.z - 1
		end
		if key == "S" then
			move_dir.z = move_dir.z + 1
		end 
	end
	if move_dir.x ~= 0 or move_dir.z ~= 0 then 
		print("move delta", move_dir.x, move_dir.z, delta)
		move_dir.x = move_dir.x * delta
		move_dir.z = move_dir.z * delta 

		local e <close> = world:entity(player, "eid:in")
		local pos = iom.get_position(e)
		local add = math3d.vector(move_dir.x, 0, move_dir.z, 1)
		local new_pos = math3d.add(pos, add)

		iom.set_position(e, new_pos)
	end
end