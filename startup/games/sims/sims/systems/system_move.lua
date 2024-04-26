local ecs = ...
local m = ecs.system "system_move"
local world = ecs.world
local w = world.w
local math3d = require "math3d"
local utils = require 'utils.utils'
local timer = ecs.require "ant.timer|timer_system"
local iom = ecs.require "ant.objcontroller|obj_motion"


local function update_move_anim(e, moving, move)
	if moving ~= move.moving then 
		move.moving = moving
		if moving then 
			utils.play_animation(world, e, "run2_loop")
		else 
			utils.play_animation(world, e, "idle_loop")
		end
	end
end

local function lerp_float(start, finish, t)
	return start * (1 - t) + finish * t
end

local function normalize(x, y)
	local size = math.sqrt(x * x + y * y)
	return x / size, y / size
end


--- 如果服务器 和 客户端都在移动
---@param s sims.msg.s2c_npc_move
local function move_lerp(e, move, delta_time, s, client_move_dir)
	local pos = s.pos
	local dir = s.dir
	local c_pos = iom.get_position(e)
	local dest = {pos[1] + dir[1], pos[2], pos[3] + dir[2]}
	local client_pos = math3d.tovalue(c_pos)
	local dir_x = dest[1] - client_pos[1]
	local dir_y = dest[2] - client_pos[2]
	local dir_z = dest[3] - client_pos[3]
	dir_x, dir_z = normalize(dir_x, dir_z)
	local rate = 0.5
	local move_dir_x = lerp_float(client_move_dir.x, dir_x, rate)
	local move_dir_z = lerp_float(client_move_dir.z, dir_z, rate)
	move_dir_x = move_dir_x * delta_time * s.speed
	move_dir_z = move_dir_z * delta_time * s.speed

	local add = math3d.vector(move_dir_x, 0, move_dir_z, 1)
	local new_pos = math3d.add(c_pos, add)
	local dir = math3d.vector(-move_dir_x, 0, -move_dir_z)

	iom.set_view(e, new_pos, dir)		
	update_move_anim(e, true, move)
end

--- 如果只是服务器在移动
---@param s sims.msg.s2c_npc_move
local function move_only_server(e, move, delta_time, s)
	local server_pos = s.pos
	local dir = s.dir
	local c_pos = iom.get_position(e)
	local client_pos = math3d.tovalue(c_pos)
	local dir_x = server_pos[1] - client_pos[1]
	local dir_y = server_pos[2] - client_pos[2]
	local dir_z = server_pos[3] - client_pos[3]
	local delta = dir_x * dir_x + dir_y * dir_y + dir_z * dir_z
	if delta <= 0.25 then -- 即距离0.5米内，直接以客户端位置为准
		local dir = math3d.vector(-dir[1], 0, -dir[2])
		iom.set_view(e, c_pos, dir)
		return;
	end

	local size = dir_x * dir_x + dir_z * dir_z
	if size < 0.1 then 
		local dir = math3d.vector(-dir[1], 0, -dir[2])
		iom.set_view(e, c_pos, dir)
		return 
	end 
	size = math.sqrt(size)
	local move_speed<const> = 8
	local x = dir_x / size * delta_time * move_speed
	local z = dir_z / size * delta_time * move_speed

	local dir = math3d.vector(-dir_x, 0, -dir_z)
	local add = math3d.vector(x, 0, z, 1)
	local new_pos = math3d.add(c_pos, add)
	iom.set_view(e, new_pos, dir)
end

--- 如果只是客户端在移动
---@param server_pos number[] 服务器位置
local function move_only_client(e, move, delta_time, server_pos)
	local move_speed<const> = 2
	local move_dir = move.move_dir
	local x = move_dir.x * delta_time * move_speed
	local z = move_dir.z * delta_time * move_speed
	local pos = iom.get_position(e)
	local add = math3d.vector(x, 0, z, 1)
	local new_pos = math3d.add(pos, add)
	local dir = math3d.vector(-x, 0, -z)

	if server_pos then 
		local p = math3d.tovalue(new_pos)
		local delta_x = p[1] - server_pos[1]
		local delta_y = p[2] - server_pos[2]
		local delta_z = p[3] - server_pos[3]
		local delta = delta_x * delta_x + delta_y * delta_y + delta_z * delta_z
		if delta >= 9 then -- 服务器客户端距离超过3米，则瞬移回服务器位置
			new_pos = math3d.vector(server_pos[1], server_pos[2], server_pos[3], 1)
		end
	end

	-- 设置玩家位置和朝向
	iom.set_view(e, new_pos, dir)
	update_move_anim(e, true, move)
end

--- 服务器和客户端都没有移动的情况下
local function move_none(e, move, delta_time, server_pos)
	update_move_anim(e, false, move)
end

--- 处理移动
function m.data_changed()
	do return end 
	
	local delta = timer.delta() * 0.001
	for e in w:select "comp_move:in" do
		local move = e.comp_move
		local move_dir = move.move_dir or {}
		local is_client_moving = move_dir.x and (move_dir.x ~= 0 or move_dir.z ~= 0)
		
		---@type sims.msg.s2c_npc_move
		local s = move.server
		if s then 
			local dir = s.dir
			local is_server_moving = dir[1] ~= 0 or dir[2] ~= 0
			if is_server_moving then 
				if is_client_moving then 
					move_lerp(e, move, delta, s, move_dir)
				else 
					move_only_server(e, move, delta, s) 
				end
			elseif is_client_moving then
				move_only_client(e, move, delta, s.pos) 
			else 
				move_none(e, move, delta, s.pos)
			end
		else 
			if is_client_moving then
				move_only_client(e, move, delta) 
			else
				move_none(e, move, delta, nil)
			end
		end
	end
end