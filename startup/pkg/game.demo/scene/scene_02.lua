local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "scene_02_system",
    category        = mgr.type_scene,
    name            = "02_pickup",
    file            = "scene/scene_02.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w
local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"
local math3d = require "math3d"
local PC  = ecs.require("utils.world_handler").proxy_creator()
local timer = ecs.require "ant.timer|timer_system"
local iom = ecs.require "ant.objcontroller|obj_motion"
local mathpkg = import_package "ant.math"
local dotween = import_package "com.dotween"
local mu      = mathpkg.util
local iviewport = ecs.require "ant.render|viewport.state"
local ipu = ecs.require "ant.objcontroller|pickup.pickup_system"
local icamera = ecs.require "ant.camera|camera"

local topick_mb
local pickup_mb
local last_entity

function system.on_entry()
	topick_mb = world:sub{"mouse", "LEFT"}
	pickup_mb = world:sub{"pickup"}

	PC:create_instance { prefab = "/pkg/game.res/light_skybox.prefab" }
	PC:create_entity{
		policy = { "ant.render|simplerender", },
		data = {
			scene = { s = {250, 1, 250}, },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible_state= "main_view",
			simplemesh 	= imesh.init_mesh(ientity.plane_mesh()),
			on_ready = function(e) 
				local main_queue = w:first "main_queue camera_ref:in"
				local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
				local dir = math3d.vector(0, -1, 1)
				local size = 4
				local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
				local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
				icamera.focus_aabb(main_camera, aabb, dir)
			end,
		}
	}

	local iom = ecs.require "ant.objcontroller|obj_motion"
	for i = 1, 3 do 
		PC:create_instance {
			prefab = "/pkg/game.res/npc/cube/cube_green.glb|mesh.prefab",
			on_ready = function(e)
				local eid = e.tag['*'][1]
				local ee<close> = world:entity(eid)
				iom.set_position(ee, math3d.vector(i * 6 - 10, 1, 5))
			end
		}

		PC:create_instance {
			prefab = "/pkg/game.res/npc/cube/cube_green.glb|mesh.prefab",
			on_ready = function(e)
				local eid = e.tag['*'][1]
				local ee<close> = world:entity(eid)
				iom.set_position(ee, math3d.vector(i * 6 - 10, 1, 2))
			end
		}
	end
end 

function system.on_leave()
	world:unsub(topick_mb)
	world:unsub(pickup_mb)
	PC:clear()
	last_entity = nil
end 

local function remap_xy(x, y)
    local vp = iviewport.device_size
    local vr = iviewport.viewrect
    local nx, ny = x - vp.x, y - vp.y
    nx, ny  = mu.convert_device_to_screen_coord(vp, vr, nx, ny)
	return nx, ny
end

local desc = 
[[
点击场景中的方块, 被选中的目标会被放大1.1倍
问题:
1. 目前点击结果是通过事件分发的, 当代码比较复杂时，
	如果有多处都在发起点击请求，我怎么知道点击结果是哪里发起的？
2. 怎么设置 谁能被点击，谁不能被点击？
]]

function system.data_changed()
	for _, _, state, x, y in topick_mb:unpack() do
        if state == "DOWN" then
			system.set_scale(last_entity, 1)
            x, y = remap_xy(x, y)
            ipu.pick(x, y, function(e, a, b)
				print("pick", e, a, b)
			end)
        end
    end

	ImGui.SetNextWindowPos(mgr.get_content_start())
    if ImGui.Begin("wnd_debug", nil, ImGui.WindowFlags {"AlwaysAutoResize", "NoMove", "NoTitleBar"}) then
		ImGui.Text(desc)
	end
	ImGui.End()
end

function system.set_scale(eid, scale)
	eid = tonumber(eid)
	if not eid then return end 

	local ee<close> = world:entity(eid)
	if ee then 
		iom.set_scale(ee, scale)
	end
end

function system.after_pickup()
	for _, eid, x, y in pickup_mb:unpack() do 
		system.set_scale(eid, 1.1)
		last_entity = eid
		break
	end
end