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
local iom   = ecs.require "ant.objcontroller|obj_motion"
local timer 	= ecs.require "ant.timer|timer_system"
local renderpkg	= import_package "ant.render"
local assetmgr  = import_package "ant.asset"
local layoutmgr = renderpkg.layoutmgr
local entities = {}

function system.on_entry()
	-- 天空盒
	PC:create_instance { 
		prefab = "/pkg/demo.res/light_skybox.prefab",
		on_ready = function() 
			local main_queue = w:first "main_queue camera_ref:in"
			local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
			local dir = math3d.vector(0, -1, 1)
			local size = 1
			local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
			local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
			icamera.focus_aabb(main_camera, aabb, dir)
		end
	}

	-- 替换plane图片
	local eid = world:create_entity {
		policy = {
			"ant.render|render",
		},
		data = {
			scene 	= { s = {10, 10, 1}, t = {0, 0, 3}, r = {math.rad(-90), 0, 0}  },
			material = "/pkg/demo.res/materials/plane.material",
			visible     = true,
			mesh        = "plane.primitive",
			on_ready = function (e)
				-- 更换默认贴图
				local tex = assetmgr.resource "/pkg/ant.resources/textures/color_text.texture"
				imaterial.set_property(e, "s_basecolor", tex.id)
			end,
		},
	}
	table.insert(entities, eid)

	-- 最下面的plane，用于展示阴影
	local eid = world:create_entity {
		policy = {
			"ant.render|render",
		},
		data = {
			scene 	= { s = {5, 1, 5}, t = {0, -1.5, 0}  },
			material = "/pkg/ant.resources/materials/mesh_shadow.material",
			visible     = true,
			mesh        = "plane.primitive",
		},
	}
	table.insert(entities, eid)

	---[[
	-- 绘制自定义plane
	PC:create_entity{
		policy = { "ant.render|simplerender" },
		data = {
			scene 		= {
				s = {0.5, 0.5, 0.5},	-- 缩放
				t = {-2, 0, 0},
            },
			material 	= "/pkg/demo.res/materials/primitive_uv.material",
			visible	= true,
			mesh_result = system.create_plane(),
			on_ready = function(e)
				imaterial.set_property(e, "u_basecolor_factor", math3d.vector(0.3, 0.3, 0.3))
			end
		}
	}

	-- 绘制坐标轴
	PC:create_entity{
		policy = {
			"ant.render|simplerender",
		},
		data = {
			scene 		= {s = 0.5, t = {0, 0, 0}},
			material	= "/pkg/ant.resources/materials/line.material",
			render_layer= "translucent",
			mesh_result	= system.create_axis(),
			visible		= true,
		}
	}

	-- 绘制自定义cube
	PC:create_entity {
        policy = {
            "ant.render|simplerender",
        },
        data = {
            scene = {s = 0.5, t = {-1, 0, 0}},
            mesh_result = system.create_cube(),
            material    = "/pkg/demo.res/materials/primitive_uv.material",
            visible     = true,
            on_ready = function (e)
                imaterial.set_property(e, "u_basecolor_factor", math3d.vector(1, 1, 1))
            end,
        },
    }
	--]]

	-- 绘制cube.glb
	PC:create_instance {
		prefab = "/pkg/demo.res/npc/cube/cube.glb/mesh.prefab",
		on_ready = function (e)
			local entity<close> = world:entity(e.tag.Cube[1])
			imaterial.set_property(entity, "u_basecolor_factor", math3d.vector(1, 0, 0, 1 )) -- 红色
			iom.set_position(entity, math3d.vector(-2, -1, -0.25))
			iom.set_scale(entity, 0.25)
		end
	}

	-- 绘制球
	local nums = {20, 80, 320, 1280}
	for i, v in ipairs(nums) do
		PC:create_entity {
			policy = {
				"ant.render|simplerender",
			},
			data = {
				scene = {s = 0.5, t = {i - 2, -1, -0.25}},
				mesh_result = system.create_sphere(v),
				material    = "/pkg/demo.res/materials/primitive.material",
				visible     = true,
				cast_shadow = true,
				visible_masks = "main_view|cast_shadow",
				on_ready = function (e)
					imaterial.set_property(e, "u_basecolor_factor", math3d.vector(i / #nums, 1 - i / #nums, 0))
				end,
			},
		}
	end

	---[[
	for i, v in ipairs({"tetrahedron", "cube", "icosahedron"}) do 
		PC:create_entity {
			policy = {
				"ant.render|simplerender",
			},
			data = {
				scene = {s = 0.5, t = {i, 0, 0}},
				mesh_result = system[string.format("create_%s", v)](),
				material    = "/pkg/ant.resources/materials/meshcolor.material",
				visible     = true,
				visible_masks = "main_view|cast_shadow",
				cast_shadow = true,
				on_ready = function (e)
					imaterial.set_property(e, "u_color", math3d.vector(0.4, 0.4, 0.4))
				end,
			},
		}

		local func_name = string.format("create_%s_wireframe", v)
		if system[func_name] then
			PC:create_entity{
				policy = {
					"ant.render|simplerender",
				},
				data = {
					scene 		= {s = 0.5, t = {i, 1, 0}},
					material	= "/pkg/ant.resources/materials/line.material",
					render_layer= "translucent",
					mesh_result	= system[func_name](),
					visible		= true,
				}
			}
		end
	end
	--]]
end 

function system.on_leave()
	PC:clear()
	for i, eid in ipairs(entities) do
		world:remove_entity(eid)
	end
	entities = {}
end

local time = 0;
function system.data_changed()
	local delta_time = timer.delta() * 0.001 * 0.5
	time = time + delta_time
	for idx, eid in ipairs(PC._entities) do 
		local e<close> = world:entity(eid)
		if e then 
			local rot = math3d.quaternion({time + idx * 0.2, time + idx * 0.35, 0})
			iom.set_rotation(e, rot)
		end
	end
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
		-- top            x   y   z  u  v
		-0.5,  0.5,  0.5, 0,  1,  0, 0, 0,
		 0.5,  0.5,  0.5, 0,  1,  0, 1, 0,
		-0.5,  0.5, -0.5, 0,  1,  0, 0, 1,
		 0.5,  0.5, -0.5, 0,  1,  0, 1, 1,
		-- bottom
		-0.5, -0.5,  0.5, 0, -1,  0, 0, 0,
		 0.5, -0.5,  0.5, 0, -1,  0, 1, 0,
		-0.5, -0.5, -0.5, 0, -1,  0, 0, 1,
		 0.5, -0.5, -0.5, 0, -1,  0, 1, 1,
		 -- front
		-0.5,  0.5, -0.5, 0,  0, -1, 0, 0,
		 0.5,  0.5, -0.5, 0,  0, -1, 1, 0,
		-0.5, -0.5, -0.5, 0,  0, -1, 0, 1,
		 0.5, -0.5, -0.5, 0,  0, -1, 1, 1,
		 -- back
		-0.5,  0.5,  0.5, 0,  0,  1, 0, 0,
		 0.5,  0.5,  0.5, 0,  0,  1, 1, 0,
		-0.5, -0.5,  0.5, 0,  0,  1, 0, 1,
		 0.5, -0.5,  0.5, 0,  0,  1, 1, 1,
		 -- left
	    -0.5, -0.5,  0.5, -1,  0, 0, 0, 0,
		-0.5,  0.5,  0.5, -1,  0, 0, 1, 0,
		-0.5, -0.5, -0.5, -1,  0, 0, 0, 1,
		-0.5,  0.5, -0.5, -1,  0, 0, 1, 1,
		-- right
	     0.5, -0.5,  0.5,  1,  0, 0, 0, 0,
		 0.5,  0.5,  0.5,  1,  0, 0, 1, 0,
		 0.5, -0.5, -0.5,  1,  0, 0, 0, 1,
		 0.5,  0.5, -0.5,  1,  0, 0, 1, 1,

	}
	local vbdata = {"p3|n3|t2", vb}
	local ibdata = {
		0,  1,  2,
		1,  3,  2,

		4,  6,  5,
		5,  6,  7,


		8,  9,  10,
		9,  11, 10,

		12,  14, 13,
		13,  14, 15,

		16,  17, 18,
		17,  19, 18,

		20,  22, 21,
		21,  22, 23,
	}
	local aabb = {{-0.5, -0.5, -0.5}, {0.5, 0.5, 0.5}}
	return create_mesh(vbdata, ibdata, aabb)
end

function system.create_cube_wireframe()
	local vb = {
													-- z = 0.5
		-0.5, 	0.5, 	0.5, 	0, 0, 1, 1,
		0.5, 	0.5, 	0.5, 	0, 1, 1, 1,
		-0.5, 	-0.5, 	0.5, 	1, 1, 1, 1,
		0.5, 	-0.5, 	0.5, 	1, 0, 1, 1,

													-- z = -0.5
		-0.5, 	0.5, 	-0.5, 	0, 0, 0, 1,
		0.5, 	0.5, 	-0.5, 	0, 1, 0, 1,
		-0.5, 	-0.5, 	-0.5, 	1, 1, 0, 1,
		0.5, 	-0.5, 	-0.5, 	1, 0, 0, 1,

	}
	local vbdata = {"p3|c4", vb}
	local ibdata = {
		0, 1, 0, 2, 
		1, 3, 2, 3,
		0, 4, 1, 5,
		2, 6, 3, 7,
		4, 5, 4, 6, 
		5, 7, 6, 7,
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

--- 绘制正四面体
--- https://danielsieger.com/blog/2021/01/03/generating-platonic-solids.html
function system.create_tetrahedron(u0, v0, u1, v1)
	if not u0 then
		u0, v0, u1, v1 = 0, 0, 1, 1
	end

	local a = 1 / 3
	local b = math.sqrt(8 / 9)
	local c = math.sqrt(2 / 9)
	local d = math.sqrt(2 / 3)
	local vb = {
		0, 	0, 	1, 	0, 1, 0, u0, v0,
		-c, d, -a, 0, 1, 0, u1, v0,
		-c, -d, -a, 0, 1, 0, u0, v1,
		b, 0, -a, 0, 1, 0, u1, v1,		
	}
	local vbdata = {"p3|n3|t2", vb}
	local ibdata = {
		0, 1, 2,
		0, 2, 3,
		0, 3, 1,
		3, 2, 1
	}
	local aabb = {{-1, -1, 1}, {1, 1, 1}}
	return create_mesh(vbdata, ibdata, aabb)
end

function system.create_tetrahedron_wireframe()
	local a = 1 / 3
	local b = math.sqrt(8 / 9)
	local c = math.sqrt(2 / 9)
	local d = math.sqrt(2 / 3)
	local vb = {
		0, 	0, 	1, 	1, 0, 0, 1,
		-c, d, -a, 0, 1, 0, 1,
		-c, -d, -a, 0, 0, 1, 1,
		b, 0, -a, 1, 1, 1, 1,
	}
	local vbdata = {"p3|c4", vb}
	local ibdata = {
		0, 1, 2,
		0, 2, 3,
		0, 3, 1,
		3, 2, 1
	}
	local aabb = {{-1, -1, 1}, {1, 1, 1}}
	return create_mesh(vbdata, ibdata, aabb)
end

function system.create_icosahedron()
	local phi = (1 + math.sqrt(5)) * 0.5
	local a = 1
	local b = 1 / phi
	local vb = {
		0, b, -a,
		b, a, 0,
		-b, a, 0,
		0, b, a,
		0, -b, a,
		-a, 0, b,
		0, -b, -a,
		a, 0, -b,
		a, 0, b,
		-a, 0, -b,
		b, -a, 0,
		-b, -a, 0,
	}

	local function norm(a, b, c)
		return math.sqrt(a * a + b * b + c * c)
	end

	local function project_to_unit_sphere(tb)
		for i = 1, #tb, 3 do 
			local a, b, c = tb[i], tb[i + 1], tb[i + 2]
			local n = 1 / norm(a, b, c)
			tb[i], tb[i + 1], tb[i + 2] = n * a, n * b, n * c
		end
	end
	project_to_unit_sphere(vb)

	local vbdata = {"p3", vb}
	local ibdata = {
		2, 1, 0, 
		1, 2, 3, 
		5, 4, 3, 
		4, 8, 3, 
		7, 6, 0, 
		6, 9, 0, 
		11, 10, 4, 
		10, 11, 6, 
		9, 5, 2, 
		5, 9, 11, 
		8, 7, 1, 
		7, 8, 10, 
		2, 5, 3, 
		8, 1, 3, 
		9, 2, 0, 
		1, 7, 0, 
		11, 9, 6,
		7, 10, 6, 
		5, 11, 4, 
		10, 8, 4, 
	}
	local aabb = {{-1, -1, 1}, {1, 1, 1}}
	return create_mesh(vbdata, ibdata, aabb)
end

function system.create_sphere(triangles)
	triangles = triangles or 1480
	local t = (1 + math.sqrt(5)) / 2
	local points = {}
	local faces = {}

	-- add vertex to mesh, fix position to be on unit sphere
	local function add_point(x, y, z)
		local length = math.sqrt(x * x + y * y + z * z)
		local v = 1 / length
		points[#points + 1] = {x * v, y * v, z * v}
	end

	-- add triangle to mesh
	local function add_triangle(p1, p2, p3, in_faces)
		local list = in_faces or faces
		list[#list + 1] = {p1, p2, p3}
	end

	-- create 12 vertices of a icosahedron
	add_point(-1, t, 0)
	add_point(1, t, 0)
	add_point(-1, -t, 0)
	add_point(1, -t, 0)

	add_point(0, -1, t)
	add_point(0, 1, t)
	add_point(0, -1, -t) 
	add_point(0, 1, -t)

	add_point(t, 0, -1)
	add_point(t, 0, 1)
	add_point(-t, 0, -1)
	add_point(-t, 0, 1)

	-- create 20 triangles of the icosahedron
	add_triangle(0, 11, 5)
	add_triangle(0, 5, 1)
	add_triangle(0, 1, 7)
	add_triangle(0, 7, 10)
	add_triangle(0, 10, 11)
	add_triangle(1, 5, 9)
	add_triangle(5, 11, 4)
	add_triangle(11, 10, 2)
	add_triangle(10, 7, 6)
	add_triangle(7, 1, 8)
	add_triangle(3, 9, 4)
	add_triangle(3, 4, 2)
	add_triangle(3, 2, 6)
	add_triangle(3, 6, 8)
	add_triangle(3, 8, 9)
	add_triangle(4, 9, 5)
	add_triangle(2, 4, 11)
	add_triangle(6, 2, 10)
	add_triangle(8, 6, 7)
	add_triangle(9, 8, 1)

	-- return index of point in the middle of p1 and p2
	local function get_middle_point(idx1, idx2)
		local p1 = points[idx1 + 1]
		local p2 = points[idx2 + 1]
		local middle = {(p1[1] + p2[1]) * 0.5, (p1[2] + p2[2]) * 0.5, (p1[3] + p2[3]) * 0.5}
		add_point(middle[1], middle[2], middle[3])
		return #points - 1;
	end

	-- refine triangles
	while #faces < triangles do 
		local faces2 = {}
		for _, f in ipairs(faces) do 
			local a = get_middle_point(f[1], f[2])
			local b = get_middle_point(f[2], f[3])
			local c = get_middle_point(f[3], f[1])
			add_triangle(f[1], a, c, faces2)
			add_triangle(f[2], b, a, faces2)
			add_triangle(f[3], c, b, faces2)
			add_triangle(a, b, c, faces2)
		end
		faces = faces2
	end

	local vb = {}
	for _, p in ipairs(points) do 
		local index = #vb
		-- POSITION
		vb[index + 1] = p[1]
		vb[index + 2] = p[2]
		vb[index + 3] = p[3]

		-- NORMAL
		vb[index + 4] = p[1]
		vb[index + 5] = p[2]
		vb[index + 6] = p[3]
	end
	local vbdata = {"p3|n3", vb}
	local ibdata = {}
	for _, f in ipairs(faces) do 
		local index = #ibdata
		ibdata[index + 1] = f[1]
		ibdata[index + 2] = f[2]
		ibdata[index + 3] = f[3]
	end
	local aabb = {{-1, -1, 1}, {1, 1, 1}}
	return create_mesh(vbdata, ibdata, aabb)
end