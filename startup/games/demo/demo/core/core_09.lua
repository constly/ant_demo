local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_09_system",
    category        = mgr.type_core,
    name            = "09_内置多边形",
    file            = "core/core_09.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w

local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"
local icamera = ecs.require "ant.camera|camera"
local math3d = require "math3d"
local imaterial = ecs.require "ant.render|material"

local PC  = ecs.require("utils.world_handler").proxy_creator()

function system.on_entry()
	PC:create_instance { 
		prefab = "/pkg/demo.res/light_skybox.prefab",
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
		policy = { "ant.render|render" },
		data = {
			scene 		= {
				s = {2, 1, 2},	-- 缩放
            },
			material 	= "/pkg/demo.res/materials/primitive.material",
			visible	= true,
			mesh = "plane.primitive",
			on_ready = function(e)
				imaterial.set_property(e, "u_basecolor_factor", math3d.vector(0, 0.8, 0.8))
			end
		}
	}

	PC:create_entity{
		policy = { "ant.render|render" },
		data = {
			scene 		= {
				s = {0.5, 0.5, 0.5},	-- 缩放
				t = {0, 0.5, 0},
            },
			material 	= "/pkg/demo.res/materials/primitive.material",
			visible	= true,
			visible_masks = "main_view|cast_shadow",
			cast_shadow = true,
			mesh = "cube.primitive",
			on_ready = function(e)
				imaterial.set_property(e, "u_basecolor_factor", math3d.vector(1, 0.2, 0.8))
			end
		}
	}

	PC:create_entity {
		policy = {
			"ant.render|render",
		},
		data = {
			scene 		= {
				s = {1, 1, 1},	-- 缩放
				t = {0, 1, 0},	-- 位置
				r = {0, math.rad(270), 0},
			},
			material 	= "/pkg/ant.resources/materials/meshcolor.material",
			visible     = true,
			mesh        = "arrow(0.3).primitive",
			on_ready = function(e)
				imaterial.set_property(e, "u_color", math3d.vector(0.8, 0.8, 0))
			end
		}
	}

	local p0 = {-1, -1, -1}
	local p1 = {3, 3, 3}
	local scene = { s= 1}
	local color = {1, 0, 0, 1}
	local hide = false
	PC:add_entity(ientity.create_line_entity(p0, p1, scene, color, hide))
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