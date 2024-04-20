local ecs = ...
local m = ecs.system "system_move"
local world = ecs.world
local w = world.w
local math3d = require "math3d"
local utils = require 'utils.utils'
local timer = ecs.require "ant.timer|timer_system"
local iom = ecs.require "ant.objcontroller|obj_motion"

--- 处理移动
function m.data_changed()
	local move_speed = 6
	local delta = timer.delta() * 0.001

	for e in w:select "comp_move:in" do
		local move = e.comp_move
		local move_dir = move.move_dir
		if move_dir then
			local moving = false
			if move_dir.x ~= 0 or move_dir.z ~= 0 then
				local x = move_dir.x * delta * move_speed
				local z = move_dir.z * delta * move_speed
				local pos = iom.get_position(e)
				local add = math3d.vector(x, 0, z, 1)
				local new_pos = math3d.add(pos, add)
				local dir = math3d.vector(-x, 0, -z)

				-- 设置玩家位置和朝向
				iom.set_view(e, new_pos, dir)
				moving = true
			end

			if moving ~= move.moving then 
				move.moving = moving
				if moving then 
					utils.play_animation(world, e, "run2_loop")
				else 
					utils.play_animation(world, e, "idle_loop")
				end
			end
		end
	end
end