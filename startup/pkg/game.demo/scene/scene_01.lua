local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "scene_01_system",
    category        = mgr.type_scene,
    name            = "01_第3人称相机",
    file            = "scene/scene_01.lua",
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
local iplayback = ecs.require "ant.animation|playback"
local ianimation = ecs.require "ant.animation|animation"

local player
local moving
local pre_anim_name  ---@type string 动画名
local p_model;  ---@type any 玩家模型
local kb_mb
local mouse_mb
local mouse_lastx, mouse_lasty
local eventGesturePinch;
local tb_keydown = {}

function system.on_entry()
	PC:create_instance { prefab = "/pkg/game.res/light_skybox.prefab" }
	PC:create_entity{
		policy = { "ant.render|simplerender", },
		data = {
			scene = { s = {250, 1, 250}, },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible	= true,
			mesh_result = imesh.init_mesh(ientity.plane_mesh(), true),
			owned_mesh_buffer = true,
		}
	}

	-- 玩家根节点
	player = PC:create_entity {
		policy = { "ant.scene|scene_object" },
		data = {
			scene = { 
				s = {1.2, 1.2, 1.2}, 
				t = {0, 0, 0}, 
				r = {0, 0, 0}
			}
		}
	}

	-- 玩家模型, 挂在player下
	p_model = PC:create_instance {
		prefab = "/pkg/game.res/npc/test_003/scene.gltf/mesh.prefab",
        on_ready = function (e)
			world:instance_set_parent(e, player)
		end,
	}
	
	
	local iom = ecs.require "ant.objcontroller|obj_motion"
	for i = 1, 3 do 
		PC:create_instance {
			prefab = "/pkg/game.res/npc/cube/cube_green.glb/mesh.prefab",
			on_ready = function(e)
				local eid = e.tag['*'][1]
				local ee<close> = world:entity(eid)
				iom.set_position(ee, math3d.vector(i * 6 - 10, 1, 5))
			end
		}
	end

	kb_mb = world:sub{"keyboard"}
	mouse_mb = world:sub {"mouse"}
	eventGesturePinch = world:sub {"gesture", "pinch"}
	world:disable_system("ant.camera|default_camera_controller")
end 

function system.on_leave()
	player = nil
	moving = nil
	pre_anim_name = nil
	tb_keydown = {}
	PC:clear()
	world:unsub(kb_mb)
	world:unsub(mouse_mb)
	world:unsub(eventGesturePinch)
	world:enable_system("ant.camera|default_camera_controller")
end


function system.data_changed()
	if not player then return end 
	
	local move_speed = 8
	for _, key, press, status in kb_mb:unpack() do
		--[[ 
			press: 
				1 - 按下 
				2 - 长按 
				0 - 按起
			state: ?
		--]]
		if press == 1 then 
			tb_keydown[key] = true 
		elseif press == 0 then 
			tb_keydown[key] = false 
		end 
	end

	local move_dir = {x = 0, z = 0}
	local delta = timer.delta() * 0.001
	for key, down in pairs(tb_keydown) do 
		if down then 
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
	end

	-- 处理玩家移动
	local pe <close> = world:entity(player)
	local _moving = false
	if move_dir.x ~= 0 or move_dir.z ~= 0 then 
		move_dir.x = move_dir.x * delta * move_speed
		move_dir.z = move_dir.z * delta * move_speed

		-- 根据摄像机角度旋转移动向量
		local degree = system.get_camera_degree(90)
		local x = move_dir.x * math.cos(degree) - move_dir.z * math.sin(degree)
		local z = move_dir.z * math.cos(degree) + move_dir.x * math.sin(degree)
		if x ~= 0 or z ~= 0 then
			local pos = iom.get_position(pe)
			local add = math3d.vector(x, 0, z, 1)
			local new_pos = math3d.add(pos, add)
			local dir = math3d.vector(-x, 0, -z)

			-- 设置玩家位置和朝向
			iom.set_view(pe, new_pos, dir)
		end
		_moving = true
	end

	if moving ~= _moving then 
		moving = _moving
		if moving then 
			system.play_anim("run2_loop")
		else 
			system.play_anim("idle_loop")
		end
	end

	system.update_camera_(pe, delta)
	system.draw_ui_debug()
end

function system.play_anim(name)
	if name == pre_anim_name then return end 

	local entities = p_model.tag['*']
	for i = 1, #entities do
		local eid = entities[i]
		local e <close> = world:entity(eid, "animation?in")
		if e and e.animation then
			if pre_anim_name then 
				iplayback.set_play(e, pre_anim_name, false)
				ianimation.set_weight(e, pre_anim_name, 0)
			end
			iplayback.set_play(e, name, true)
			iplayback.completion_loop(e, name)
			ianimation.set_weight(e, name, 1)
		end
	end
	pre_anim_name = name
end

------------------------------------------------------------------------------
--- 摄像机移动相关
------------------------------------------------------------------------------
local camera_cfg = {
	-- 摄像机距离玩家平面距离
	dis = 10,

	-- 摄像机高度
	height = 7,

	-- 摄像机旋转角度
	angle = 0,

	-- 视点偏移
	offset_y = 0,
	offset_x = 0,
	offset_z = 0,

	-- 摄像机旋转速度
	rotate_speed = 135,

	reset = function(self)
		self.dis = 10
		self.height = 7
		self.offset_y = 0
		self.offset_x = 0
		self.offset_z = 0
	end
}

local camera_move_type = 1
local tb_camera_move_type = {
	"跟随玩家",
	"固定动画",
	"自由拖动水平",
	"自由拖动360",
}

function system.get_camera_degree(offset)
	return (camera_cfg.angle + (offset or 0)) / 180 * math.pi 
end

function system.update_camera_(pe, delta_time)
	local mq = w:first("main_queue camera_ref:in render_target:in")
	local ce <close> = world:entity(mq.camera_ref, "scene:update")
	local pos = iom.get_position(pe)
	local tpos = math3d.tovalue(pos)	-- 玩家位置

	for _, btn, state, x, y in mouse_mb:unpack() do
		-- 旋转镜头
		if btn == "RIGHT" then
			if state == "DOWN" then
				mouse_lastx, mouse_lasty = x, y
			elseif state == "MOVE" then
				local delta_x, delta_y = x - mouse_lastx, y - mouse_lasty
				mouse_lastx, mouse_lasty = x, y

				if delta_x ~= 0 then 
					local move = delta_time * camera_cfg.rotate_speed
					camera_cfg.angle = camera_cfg.angle + (delta_x > 0 and -move or move)
				end
			end
		elseif btn == "MIDDLE" then
			
		end
	end

	for _, _, e in eventGesturePinch:unpack() do
		local v = e.velocity * -0.03
        camera_cfg.dis = camera_cfg.dis + camera_cfg.dis * v
		camera_cfg.height = camera_cfg.height + camera_cfg.height * v
    end

	local degree = system.get_camera_degree(90)
	local offset_x = camera_cfg.offset_x * math.cos(degree) - camera_cfg.offset_z * math.sin(degree)
	local offset_z = camera_cfg.offset_z * math.cos(degree) + camera_cfg.offset_x * math.sin(degree)
	local view_target = math3d.vector(tpos[1] + offset_x, tpos[2] + camera_cfg.offset_y, tpos[3] + offset_z)
	tpos = math3d.tovalue(view_target)

	local degree = system.get_camera_degree() 
	local new_x = tpos[1] + math.cos(degree) * camera_cfg.dis;
	local new_y = tpos[2] + camera_cfg.height
	local new_z = tpos[3] + math.sin(degree) * camera_cfg.dis
	local camera_pos = math3d.vector(new_x, new_y, new_z)

	local viewdir = math3d.sub(view_target, camera_pos) 
	iom.lookto(ce, camera_pos, viewdir)
end

------------------------------------------------------------------------------
--- debug ui
------------------------------------------------------------------------------

local text_dis = ImGui.StringBuf()
local slider_dis = { [1] = 0 }
local slider_height = { [1] = 0 }
local slider_offset_x = { [1] = 0 }
local slider_offset_y = { [1] = 0 }
local slider_offset_z = { [1] = 0 }

function system.draw_ui_debug()
	local posx, posy = mgr.get_content_start()
	local sizex, sizey = mgr.get_content_size()
	local btn_size = 220
	ImGui.SetNextWindowPos(posx + sizex - btn_size, posy)
	ImGui.SetNextWindowSize(btn_size, sizey)
	if ImGui.Begin("wnd_ui_debug", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("相机移动类型:")
		ImGui.SetNextItemWidth(200)
        if ImGui.BeginCombo("##combo_camera_move_type", tb_camera_move_type[camera_move_type]) then
            for i, name in ipairs(tb_camera_move_type) do
                if ImGui.Selectable(name, i == camera_move_type) then
                    camera_move_type = i
                end
            end
            ImGui.EndCombo()
        end

		if camera_move_type == 1 then
			ImGui.Text("水平距离:")
			ImGui.SameLineEx(120)
			ImGui.SetNextItemWidth(90)
			slider_dis[1] = camera_cfg.dis
			if ImGui.SliderFloat("##slider_dis", slider_dis, 1, 20) then 
				camera_cfg.dis = slider_dis[1]
			end

			ImGui.Text("相机高度:")
			ImGui.SameLineEx(120)
			ImGui.SetNextItemWidth(90)
			slider_height[1] = camera_cfg.height
			if ImGui.SliderFloat("##slider_height", slider_height, 1, 20) then 
				camera_cfg.height = slider_height[1]
			end

			ImGui.Text("视点偏移x:")
			ImGui.SameLineEx(120)
			ImGui.SetNextItemWidth(90)
			slider_offset_x[1] = camera_cfg.offset_x
			if ImGui.SliderFloat("##slider_offset_x", slider_offset_x, -5, 5) then 
				camera_cfg.offset_x = slider_offset_x[1]
			end

			ImGui.Text("视点偏移y:")
			ImGui.SameLineEx(120)
			ImGui.SetNextItemWidth(90)
			slider_offset_y[1] = camera_cfg.offset_y
			if ImGui.SliderFloat("##slider_offset_y", slider_offset_y, -5, 5) then 
				camera_cfg.offset_y = slider_offset_y[1]
			end

			ImGui.Text("视点偏移z:")
			ImGui.SameLineEx(120)
			ImGui.SetNextItemWidth(90)
			slider_offset_z[1] = camera_cfg.offset_z
			if ImGui.SliderFloat("##slider_offset_z", slider_offset_z, -5, 5) then 
				camera_cfg.offset_z = slider_offset_z[1]
			end
		end

		if ImGui.ButtonEx("重 置##btn_reset", 80) then 
			camera_cfg.reset(camera_cfg)
		end
	end 
	ImGui.End()
end