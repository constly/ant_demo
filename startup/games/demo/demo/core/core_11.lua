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
local imesh 	= ecs.require "ant.asset|mesh"
local renderpkg	= import_package "ant.render"
local layoutmgr = renderpkg.layoutmgr

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

	-- 怎么给panel/cube设置贴图？
	PC:create_entity{
		policy = { "ant.render|simplerender" },
		data = {
			scene 		= {
				s = {5, 1, 5},	-- 缩放
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible	= true,
			mesh_result = system.create_plane(),
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
            material    = "/pkg/ant.resources/materials/meshcolor.material",
            visible     = true,
            on_ready = function (e)
                imaterial.set_property(e, "u_color", math3d.vector(1, 1, 1))
            end,
        },
    }

	world:create_entity{
		policy = {
			"ant.render|simplerender",
		},
		data = {
			scene 		= {s = 0.5, t = {-1, 0, -1}},
			material	= "/pkg/ant.resources/materials/line.material",
			render_layer= "translucent",
			mesh_result	= system.create_axis(),
			visible		= true,
		}
	}
end 

function system.on_leave()
	PC:clear()
end

local function create_mesh(vbdata, ibdata, aabb)
	local vb = {
		start = 0,
	}
	local mesh = {vb = vb}

	if aabb then
		mesh.bounding = {aabb=aabb}
	end
	
	local correct_layout = layoutmgr.correct_layout(vbdata[1]) -- 'p30NIf|n30NIf|t20NIf'
	local flag = layoutmgr.vertex_desc_str(correct_layout)

	vb.num = #vbdata[2] // #flag
	vb.declname = correct_layout
	vb.memory = {flag, vbdata[2]}

	if ibdata then
		mesh.ib = {
			start = 0, num = #ibdata,
			memory = {"w", ibdata},
		}
	end
	return imesh.init_mesh(mesh)
end

function system.create_plane(u0, v0, u1, v1)
	if not u0 then
		u0, v0, u1, v1 = 0, 0, 1, 1
	end
	local vb = {
		-0.5, 0, 0.5, 0, 1, 0, u0, v0,	--left top
		 0.5, 0, 0.5, 0, 1, 0, u1, v0,	--right top
		-0.5, 0,-0.5, 0, 1, 0, u0, v1,	--left bottom
		 0.5, 0,-0.5, 0, 1, 0, u1, v1,	--right bottom
	}
	local vbdata = {"p3|n3|t2", vb}
	local ibdata = {0, 1, 2, 1, 3, 2}   -- 以顺时针方向绘制三角面
	local aabb = {{-0.5, 0, -0.5}, {0.5, 0, 0.5}}
	return create_mesh(vbdata, ibdata, aabb)
end

function system.create_cube(u0, v0, u1, v1)
	if not u0 then
		u0, v0, u1, v1 = 0, 0, 1, 1
	end
	local vb = {
													-- z = 0.5
		-0.5, 	0.5, 	0.5, 	0, 1, 0, u0, v0,	--left top
		0.5, 	0.5, 	0.5, 	0, 1, 0, u1, v0,	--right top
		-0.5, 	-0.5, 	0.5, 	0, 1, 0, u0, v1,	--left bottom
		0.5, 	-0.5, 	0.5, 	0, 1, 0, u1, v1,	--right bottom

													-- z = -0.5
		-0.5, 	0.5, 	-0.5, 	0, 1, 0, u0, v0,	--left top
		0.5, 	0.5, 	-0.5, 	0, 1, 0, u1, v0,	--right top
		-0.5, 	-0.5, 	-0.5, 	0, 1, 0, u0, v1,	--left bottom
		0.5, 	-0.5, 	-0.5, 	0, 1, 0, u1, v1,	--right bottom

	}
	local vbdata = {"p3|n3|t2", vb}
	--local ibdata = {0, 1, 2, 3, 7, 1, 5, 0, 4, 2, 6, 7, 4, 5,}  
	local ibdata = {
		0, 1, 2, -- 0
		1, 3, 2,
		4, 6, 5, -- 2
		5, 6, 7,
		0, 2, 4, -- 4
		4, 2, 6,
		1, 5, 3, -- 6
		5, 7, 3,
		0, 4, 1, -- 8
		4, 5, 1,
		2, 3, 6, -- 10
		6, 3, 7,
	}
	local aabb = {{-0.5, -0.5, -0.5}, {0.5, 0.5, 0.5}}
	return create_mesh(vbdata, ibdata, aabb)
end

function system.create_axis()
	local r = {1, 0, 0, 1} 
	local g = {0, 1, 0, 1}
	local b = {0, 0, 1, 1}
	local axis_vb = {
		0, 0, 0, r[1], r[2], r[3], r[4],
		1, 0, 0, r[1], r[2], r[3], r[4],
		0, 0, 0, g[1], g[2], g[3], g[4],
		0, 1, 0, g[1], g[2], g[3], g[4],
		0, 0, 0, b[1], b[2], b[3], b[4],
		0, 0, 1, b[1], b[2], b[3], b[4],
	}
	return create_mesh{"p3|c4", axis_vb}
end