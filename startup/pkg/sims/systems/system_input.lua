local ecs = ...
local m = ecs.system "system_input"
local world = ecs.world
local timer = ecs.require "ant.timer|timer_system"
local kb_mb
local mouse_mb
local eventGesturePinch;
local tb_keydown = {}
local uitls = require 'utils.utils'

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

---@param client sims.client
---@param comp_camera comp_camera
---@param npc sims.client.npc
local function process_keyboard(client, comp_camera, npc)
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

	local e<close> = world:entity(npc.root, "comp_move:update")
	if e then 
		if move_dir.x ~= 0 or move_dir.z ~= 0 then 
			local degree = uitls.get_camera_degree(comp_camera, 90)						
			local x = move_dir.x * math.cos(degree) - move_dir.z * math.sin(degree)
			local z = move_dir.z * math.cos(degree) + move_dir.x * math.sin(degree)
			move_dir.x = x
			move_dir.z = z
		end
		local last_dir = client.player_ctrl.move_dir
		if not last_dir or (last_dir.x ~= move_dir.x or last_dir.z ~= move_dir.z) then 
			client.player_ctrl.move_dir = move_dir
			client.call_server(client.msg.rpc_set_move_dir, {dir = move_dir})
		end
		--e.comp_move.move_dir = move_dir
	end
end

local mouse_lastx, mouse_lasty
---@param comp_camera comp_camera
local function process_mouse(comp_camera)
	local delta_time = timer.delta() * 0.001
	for _, btn, state, x, y in mouse_mb:unpack() do
		-- 旋转镜头
		if btn == "RIGHT" then
			if state == "DOWN" then
				mouse_lastx, mouse_lasty = x, y
			elseif state == "MOVE" then
				local delta_x, delta_y = x - mouse_lastx, y - mouse_lasty
				mouse_lastx, mouse_lasty = x, y

				if delta_x ~= 0 then 
					local move = delta_time * comp_camera.rotate_speed
					comp_camera.angle = comp_camera.angle + (delta_x > 0 and -move or move)
				end
			end
		elseif btn == "MIDDLE" then
			
		end
	end

	for _, _, e in eventGesturePinch:unpack() do
		local v = e.velocity * -0.06
        comp_camera.dis = comp_camera.dis + comp_camera.dis * v
		comp_camera.height = comp_camera.height + comp_camera.height * v
    end
end

-- 处理输入
function m.stage_input_process()
	---@type sims.client
	local client = world.client
	local eid = client.player_ctrl.e_camera
	local npc = client.player_ctrl.get_npc()
	if not eid or not npc then return end 

	local e<close> = world:entity(eid, "comp_camera?in")
	---@type comp_camera
	local camera_cfg = e.comp_camera
	if not camera_cfg.angle then 
		camera_cfg.dis = 10					-- 摄像机距离玩家平面距离
		camera_cfg.height = 7				-- 摄像机高度
		camera_cfg.angle = 270				-- 摄像机旋转角度
		camera_cfg.offset_y = 0				-- 视点偏移
		camera_cfg.offset_x = 0
		camera_cfg.offset_z = 0
		camera_cfg.rotate_speed = 270		-- 摄像机旋转速度
	end

	process_keyboard(client, camera_cfg, npc)
	process_mouse(camera_cfg)
end


