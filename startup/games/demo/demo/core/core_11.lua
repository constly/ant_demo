local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_11_system",
    category        = mgr.type_core,
    name            = "11_创建自定义mesh",
    file            = "core/core_11.lua",
    ok              = true
}
local bgfx = require "bgfx"
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w
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
				s = {5, 1, 5},	-- 缩放
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible	= true,
			mesh = "plane.primitive",
			on_ready = function(e)
				imaterial.set_property(e, "u_basecolor_factor", math3d.vector(0.3, 0.3, 0.3))
			end
		}
	}

	PC:create_entity {
        policy = {
            "ant.render|simplerender",
        },
        data = {
            scene = {s = 0.5, t = {0, 1, 0}},
            mesh_result = system.create_cube(),
            material    = "/pkg/ant.resources/materials/mesh_shadow.material",
            visible     = true,
            visible_masks = "main_view|selectable",
            on_ready = function (e)
                imaterial.set_property(e, "u_basecolor_factor", math3d.vector(1, 1, 0))
            end,
        },
    }
end 

function system.on_leave()
	PC:clear()
end

function system.create_cube()
	local vdecl = bgfx.vertex_layout {
		{ "POSITION", 3, "FLOAT" },
		{ "COLOR0", 4, "UINT8", true },
	}

	local buf = bgfx.memory_buffer(16 * 8)
	buf[1]    = string.pack("fffL", -1.0,  1.0,  1.0, 0xff000000)
	buf[16+1] = string.pack("fffL", 1.0,  1.0,  1.0, 0xff0000ff)
	buf[32+1] = string.pack("fffL", -1.0, -1.0,  1.0, 0xff00ff00)
	buf[48+1] = string.pack("fffL", 1.0, -1.0,  1.0, 0xff00ffff)
	buf[64+1] = string.pack("fffL", -1.0,  1.0, -1.0, 0xffff0000)
	buf[80+1] = string.pack("fffL", 1.0,  1.0, -1.0, 0xffff00ff)
	buf[96+1] = string.pack("fffL", -1.0, -1.0, -1.0, 0xffffff00)
	buf[112+1] = string.pack("fffL", 1.0, -1.0, -1.0, 0xffffffff)

	return {
		vb = {
			start = 0,
			num = 128,
			handle = bgfx.create_vertex_buffer(buf, vdecl)
		},
		ib = {
			start = 0,
			num = 14,
			handle = bgfx.create_index_buffer{
				0, 1, 2, 3, 7, 1, 5, 0, 4, 2, 6, 7, 4, 5,
			}
		}
	}
end