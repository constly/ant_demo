local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_15_system",
    category        = mgr.type_core,
    name            = "15_hitch",
    file            = "core/core_15.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w

local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.render|components.entity"
local math3d= require "math3d"
local iom   = ecs.require "ant.objcontroller|obj_motion"
local ig    = ecs.require "ant.group|group"
local PC  = ecs.require("utils.world_handler").proxy_creator()
local icamera = ecs.require "ant.camera|camera"

local hitchs = {}
local TEST_INDIRECT<const> = false

function system.on_entry()
	local group_name = "group_core_15"
	local hitch_test_group_id<const> = ig.has(group_name) and ig.groupid(group_name) or ig.register (group_name)
	
	PC:create_instance { 
		prefab = "/pkg/game.res/light.prefab",
		on_ready = function() 
			local main_queue = w:first "main_queue camera_ref:in"
			local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
			local dir = math3d.vector(0, -1, 1)
			local size = 4
			local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
			local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
			icamera.focus_aabb(main_camera, aabb, dir)
		end
	}

	PC:create_entity{
		policy = { "ant.render|simplerender" },
		data = {
			scene = {
				s = {30, 1, 30},	-- 缩放
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible_state= "main_view",
			simplemesh 	= imesh.init_mesh(ientity.plane_mesh()),
			on_ready = function(e)
			end,
		}
	}

	PC:create_instance {
        group = hitch_test_group_id,
        prefab = "/pkg/game.res/npc/cube/cube_red.glb|mesh.prefab",
        on_ready = function (p)
            local root<close> = world:entity(p.tag['*'][1], "scene:update")
            iom.set_position(root, math3d.vector(0, 2, 0))
        end,
    }

	hitchs = {}
	for i = 1, 10 do 
		local posx, posy, posz = i * 2 - 10, 5, 1
		local h = PC:create_entity {
			policy = {
				"ant.render|hitch_object",
			},
			data = {
				scene = {
					t = {posx, posy, posz},
					s = 0.5
				},
				hitch = {
					group = hitch_test_group_id
				},
				visible_state = "main_view",
				hitch_create = TEST_INDIRECT,
			}
		}
		table.insert(hitchs, {h = h, angle = i * 45, pos = {posx, posy, posz}} )
	end

	ig.enable_from_name(group_name, "view_visible", true)
end 

function system.on_leave()
	PC:clear()
end 

function system.data_changed()
	local timer = ecs.require "ant.timer|timer_system"
	local delta = timer.delta() * 0.001
	for _, data in ipairs(hitchs) do
		local e <close> = world:entity(data.h)
		data.angle = data.angle + delta * 90
		local offset = math.sin(data.angle / 180 * math.pi )
   		iom.set_position(e, math3d.vector(data.pos[1], data.pos[2] + offset, data.pos[3])) 
	end

	ImGui.SetNextWindowPos(mgr.get_content_start())
    if ImGui.Begin("wnd_debug", nil, ImGui.WindowFlags {"AlwaysAutoResize", "NoMove", "NoTitleBar"}) then
		ImGui.Text("场景中只有一个真实方块, 其他全是通过hitch批量渲染\n所有方块除了位置旋转缩放不一样, 其他属性共享")
	end
end