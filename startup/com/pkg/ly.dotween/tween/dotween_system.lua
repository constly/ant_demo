local ecs = ...
local system = ecs.system "dotween_system"
local tween = require 'tween.tween'

local time = 0
function system.init_world()
	time = os.clock()
end

function system.data_changed()
	local current = os.clock()
	local dt = current - time
	local list = tween.tweens;
	for i, v in ipairs(list) do 
		if not v.is_killed() then
			v.update(dt)
		end 
		if v.is_killed() then 
			table.remove(list, i)
		end
	end
	time = current
end