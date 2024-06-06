local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_14_system",
    category        = mgr.type_core,
    name            = "14_EntityGroup",
    file            = "core/core_14.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w

local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"
local icamera = ecs.require "ant.camera|camera"
local math3d = require "math3d"
local iom = ecs.require "ant.objcontroller|obj_motion"
local ig    = ecs.require "ant.group|group"
local irender = ecs.require "ant.render|render"
local PC  = ecs.require("utils.world_handler").proxy_creator()
local selected = {}

function system.on_entry()
	PC:create_instance { 
		prefab = "/pkg/demo.res/light_skybox.prefab",
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
		policy = { "ant.render|render" },
		data = {
			scene 		= {
				s = {30, 1, 30},	-- 缩放
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible	= true,
			mesh = "plane.primitive",
		}
	}


	for i, type in ipairs({"red", "yellow", "green", "black"}) do 
		local group_name = "Group" .. i
		local g = ig.has(group_name) and ig.groupid(group_name) or ig.register (group_name)
		for j = 1, 3 do 
			PC:create_instance {
				group = g,
				prefab = string.format("/pkg/demo.res/npc/cube/cube_%s.glb/mesh.prefab", type),
				on_ready = function(e)
					local entities = e.tag['*']
					local eid = entities[1]
					local ee<close> = world:entity(eid)
					iom.set_position(ee, math3d.vector(j * 6 - 10, 0, i * 3 - 6))

					-- for _, id in ipairs(entities) do 
					-- 	w:group_add(i, id)
					-- end
				end
			}
		end
		selected[i] = {group_name = group_name, enable = true, gid = g}
		ig.enable_from_name(group_name, "view_visible", true)
	end 
end 

function system.on_leave()
	PC:clear()
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    if ImGui.Begin("wnd_entities", nil, ImGui.WindowFlags {"AlwaysAutoResize", "NoMove", "NoTitleBar"}) then
		ImGui.Text("显示/隐藏Group:")
        for i, data in ipairs(selected) do
			if ImGui.RadioButton(string.format("Group %d##radio_id_1", i), data.enable) then 
				data.enable = not data.enable
				
				local go = ig.obj "view_visible"
    			go:enable(data.gid, data.enable)
    			irender.group_flush(go)
			end
		end
	end
	ImGui.End()
end