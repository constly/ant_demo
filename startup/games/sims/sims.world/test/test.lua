---------------------------------------------------------
--- 1. 测试寻路功能
--- 2. 测试寻路性能
---------------------------------------------------------

local world_impl = require 'sims.world.impl'

local function new()
	---@class ly.astar.test
	local api = {}

	function api.run()
		local world = world_impl.CreateWorld();
		world:Destroy()
		world = nil
		print("test")
	end

	return api
end

return {new = new}