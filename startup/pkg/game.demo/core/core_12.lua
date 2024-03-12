local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_12_system",
    category        = mgr.type_core,
    name            = "12_特效播放",
    file            = "core/core_12.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w

local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"
local icamera = ecs.require "ant.camera|camera"
local math3d = require "math3d"
local iefk      = ecs.require "ant.efk|efk"
local PC  = ecs.require("utils.world_handler").proxy_creator()

function system.on_entry()
	PC:create_instance { 
		prefab = "/pkg/game.res/light_skybox.prefab",
		on_ready = function() 
			local main_queue = w:first "main_queue camera_ref:in"
			local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
			local dir = math3d.vector(0, -1, 1)
			local boxcorners = {math3d.vector(-1.0, -1.0, -1.0), math3d.vector(1.0, 1.0, 1.0)}
			local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
			icamera.focus_aabb(main_camera, aabb, dir)
		end
	}

	PC:create_entity{
		policy = { "ant.render|simplerender" },
		data = {
			scene 		= {
				s = {3, 1, 3},	-- 缩放
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible	= true,
			mesh_result = imesh.init_mesh(ientity.plane_mesh(), true),
			owned_mesh_buffer = true,
		}
	}

	-- PC:create_entity {
	-- 	policy = {
	-- 		"ant.scene|scene_object",
	-- 		"ant.efk|efk",
	-- 	},
	-- 	data = {
	-- 		scene = {t = {0, 0.5, 0}, r = {0, 230, 0}, s = 0.5},
	-- 		efk = {
	-- 			path = "/pkg/game.res/efk/00_Basic/Laser01.efk",
	-- 		},
	-- 		visible_state = "main_queue",
	-- 	}
	-- }
	
	
end

function system.on_leave()
	PC:clear()
end

--function system.data_changed()
	-- ImGui.SetNextWindowPos(mgr.get_content_start())
    -- ImGui.SetNextWindowSize(mgr.get_content_size())
    -- if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
	-- 	ImGui.Text("待定")
	-- end 
	-- ImGui.End()
--end