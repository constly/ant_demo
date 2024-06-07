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

local light
local entities = {}

function system.on_entry()
	light = world:create_instance { 
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

	local e = world:create_entity{
		policy = { "ant.render|render" },
		data = {
			scene 		= {
				s = {1, 1, 1},	-- 缩放
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible	= true,
			mesh = "plane.primitive",
		}
	}
	table.insert(entities, e)

	local e = world:create_entity {
		policy = {
			"ant.render|render",
		},
		data = {
			scene 		= {
				s = {1, 1, 1},	-- 缩放
				t = {0, 1, 0},	-- 位置
			},
			material 	= "/pkg/ant.resources/materials/meshcolor.material",
			visible     = true,
			mesh        = "arrow(0.3).primitive",
		}
	}
	table.insert(entities, e)

	local p0 = {-1, -1, -1}
	local p1 = {3, 3, 3}
	local scene = { s= 1}
	local color = {1, 0, 0, 1}
	local hide = false
	local e = ientity.create_line_entity(p0, p1, scene, color, hide)
	table.insert(entities, e)
end

function system.on_leave()
	world:remove_instance(light)
	for i, v in ipairs(entities) do 
		world:remove_entity(v)
	end
	entities = {}
end

--function system.data_changed()
	-- ImGui.SetNextWindowPos(mgr.get_content_start())
    -- ImGui.SetNextWindowSize(mgr.get_content_size())
    -- if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
	-- 	ImGui.Text("待定")
	-- end 
	-- ImGui.End()
--end