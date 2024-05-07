---@class sims.world.main
local api = {}
local world_impl = require 'sims.world.impl'

function api.run_test()
	print("begin sims.world.main run_test")
	---@class ly.astar.test
	local api = require 'test.test'.new()
	api.run()
end

--- 创建世界
---@return sims.world.c_world 
function api.create_world()
	return world_impl.CreateWorld()
end

---@return sims.world.GridType
function api.get_grid_def()
	return world_impl.GridType
end

---@return sims.world.WalkType
function api.get_walk_type()
	return world_impl.WalkType
end

---@return number
function api.get_invalid_num()
	return world_impl.InValidNum
end

return api