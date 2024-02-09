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
local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.render|components.entity"
local math3d = require "math3d"
local PC  = ecs.require("utils.world_handler").proxy_creator()
local timer = ecs.require "ant.timer|timer_system"
local iom = ecs.require "ant.objcontroller|obj_motion"

local player
local kb_mb
local mouse_mb
local mouse_lastx, mouse_lasty

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

	-- 玩家根节点
	player = PC:create_entity {
		policy = { "ant.scene|scene_object" },
		data = {
			scene = {
				s = {0.4, 0.4, 0.4},
				t = {0, 0, 0},
				r = {0, 0, 0},
			}
		}
	}

	-- 玩家模型, 为player下的子节点
	PC:create_instance {
		prefab = "/pkg/game.res/npc/test_002/test_002.glb|mesh.prefab",
        on_ready = function (e)
			world:instance_set_parent(e, player)
		end,
	}
	
	
	local iom = ecs.require "ant.objcontroller|obj_motion"
	for i = 1, 3 do 
		PC:create_instance {
			prefab = "/pkg/ant.resources.binary/meshes/base/cube.glb|mesh.prefab",
			on_ready = function(e)
				local eid = e.tag['*'][1]
				local ee<close> = world:entity(eid)
				iom.set_position(ee, math3d.vector(i * 6 - 10, 1, 5))
			end
		}
	end

	kb_mb = world:sub{"keyboard"}
	mouse_mb = world:sub {"mouse"}
	world:disable_system("ant.camera|default_camera_controller")
end 

function system.on_leave()
	PC:clear()
	world:unsub(kb_mb)
	world:unsub(mouse_mb)
	world:enable_system("ant.camera|default_camera_controller")
end


function system.data_changed()
	local move_dir = {x = 0, z = 0}
	local delta = timer.delta() * 0.001
	local move_speed = 8
	for _, key, press, status in kb_mb:unpack() do
        --local pressed = press == 1 or press == 0
        if key == "D" then
            move_dir.x = move_dir.x + 1
		end
		if key == "A" then 
			move_dir.x = move_dir.x - 1
		end
		if key == "W" then 
			move_dir.z = move_dir.z + 1
		end
		if key == "S" then
			move_dir.z = move_dir.z - 1
		end 
	end

	local pe <close> = world:entity(player)
	if move_dir.x ~= 0 or move_dir.z ~= 0 then 
		move_dir.x = move_dir.x * delta * move_speed
		move_dir.z = move_dir.z * delta * move_speed

		-- 根据摄像机角度旋转移动向量
		local degree = system.get_camera_degree(90)
		local x = move_dir.x * math.cos(degree) - move_dir.z * math.sin(degree)
		local z = move_dir.z * math.cos(degree) + move_dir.x * math.sin(degree)

		local pos = iom.get_position(pe)
		local add = math3d.vector(x, 0, z, 1)
		local new_pos = math3d.add(pos, add)

		-- 设置玩家位置
		iom.set_position(pe, new_pos)
	end

	system.update_camera_(pe, delta)
end



------------------------------------------------------------------------------
--- 摄像机移动相关
------------------------------------------------------------------------------
do 
	-- 摄像机距离玩家平面距离
	local dis = 10;

	-- 摄像机高度
	local height = 7;

	-- 摄像机旋转角度
	local angle = 0;

	-- 视野Y偏移
	local offset_y = 0;

	function system.get_camera_degree(offset)
		return (angle + (offset or 0)) / 180 * math.pi 
	end

	---@param entity player 玩家
	---@param float delta_time 更新间隔 
	---@param mouse_delta_x 鼠标移动x
	---@param mouse_delta_y 鼠标移动y
	---@return nil
	function system.update_camera_(pe, delta_time)
		local mq = w:first("main_queue camera_ref:in render_target:in")
		local ce <close> = world:entity(mq.camera_ref, "scene:update")
		local pos = iom.get_position(pe)
		local tpos = math3d.tovalue(pos)

		for _, btn, state, x, y in mouse_mb:unpack() do
			-- 旋转镜头
			if btn == "RIGHT" then
				if state == "DOWN" then
					mouse_lastx, mouse_lasty = x, y
				elseif state == "MOVE" then
					local delta_x, delta_y = x - mouse_lastx, y - mouse_lasty
					mouse_lastx, mouse_lasty = x, y

					if delta_x ~= 0 then 
						local move = delta_time * 135
						angle = angle + (delta_x > 0 and -move or move)
					end
					if delta_y ~= 0 then 
						offset_y = offset_y - delta_y * 0.1
						offset_y = math.max(-1, offset_y)
						offset_y = math.min(6, offset_y)
					end
				end
			end
		end

		local degree = system.get_camera_degree() 
		local new_x = tpos[1] + math.cos(degree) * dis;
		local new_y = tpos[2] + height
		local new_z = tpos[3] + math.sin(degree) * dis
		local camera_pos = math3d.vector(new_x, new_y, new_z)
		local view_target = math3d.vector(tpos[1], tpos[2] + offset_y, tpos[3])
		local viewdir = math3d.sub(view_target, camera_pos) 
		iom.lookto(ce, camera_pos, viewdir)
	end
end