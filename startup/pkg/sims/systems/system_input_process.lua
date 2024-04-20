local ecs = ...
local m = ecs.system "system_input_process"
local world = ecs.world
local w = world.w
local math3d = require "math3d"
local timer = ecs.require "ant.timer|timer_system"
local iom = ecs.require "ant.objcontroller|obj_motion"
local kb_mb
local mouse_mb
local eventGesturePinch;
local tb_keydown = {}
local moving

function m.init()
	kb_mb = world:sub{"keyboard"}
	mouse_mb = world:sub {"mouse"}
	eventGesturePinch = world:sub {"gesture", "pinch"}
end 

function m.exit()
	world:unsub(kb_mb)
	world:unsub(mouse_mb)
	world:unsub(eventGesturePinch)
end

function m.stage_input_process()
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
end

function m.data_changed()
	local move_speed = 8
	---@type sims.client
	local client = world.client
	if not client then return end 

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

	local npc = client.npc_mgr.get_npc_by_id(1)
	if not npc then return end 

	-- 处理玩家移动
	local pe <close> = world:entity(npc.root)
	local _moving = false
	if move_dir.x ~= 0 or move_dir.z ~= 0 then 
		move_dir.x = move_dir.x * delta * move_speed
		move_dir.z = move_dir.z * delta * move_speed

		-- 根据摄像机角度旋转移动向量
		local degree = m.get_camera_degree(90)
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
			npc.play_anim("run2_loop")
		else 
			npc.play_anim("idle_loop")
		end
	end

	m.update_camera_(pe, delta)
end


local camera_cfg = {
	-- 摄像机距离玩家平面距离
	dis = 10,

	-- 摄像机高度
	height = 7,

	-- 摄像机旋转角度
	angle = 270,

	-- 视点偏移
	offset_y = 0,
	offset_x = 0,
	offset_z = 0,

	-- 摄像机旋转速度
	rotate_speed = 135,
}
function m.get_camera_degree(offset)
	return (camera_cfg.angle + (offset or 0)) / 180 * math.pi 
end


local mouse_lastx, mouse_lasty
function m.update_camera_(pe, delta_time)
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

	local degree = m.get_camera_degree(90)
	local offset_x = camera_cfg.offset_x * math.cos(degree) - camera_cfg.offset_z * math.sin(degree)
	local offset_z = camera_cfg.offset_z * math.cos(degree) + camera_cfg.offset_x * math.sin(degree)
	local view_target = math3d.vector(tpos[1] + offset_x, tpos[2] + camera_cfg.offset_y, tpos[3] + offset_z)
	tpos = math3d.tovalue(view_target)

	local degree = m.get_camera_degree() 
	local new_x = tpos[1] + math.cos(degree) * camera_cfg.dis;
	local new_y = tpos[2] + camera_cfg.height
	local new_z = tpos[3] + math.sin(degree) * camera_cfg.dis
	local camera_pos = math3d.vector(new_x, new_y, new_z)

	local viewdir = math3d.sub(view_target, camera_pos) 
	iom.lookto(ce, camera_pos, viewdir)
end