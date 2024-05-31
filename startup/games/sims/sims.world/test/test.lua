---------------------------------------------------------
--- 1. 测试寻路功能
--- 2. 测试寻路性能
---------------------------------------------------------

local world_impl = require 'sims.world.impl'

---@type ly.common
local common = import_package 'ly.common'

local function new()
	---@class ly.astar.test
	local api = {}

	function api.run()
		local world = world_impl.CreateWorld();
	 	local tb = world:FindPath(1, 1, 1, 5, 5, 5, 1, 1)

		common.lib.dump(tb)

		world:Destroy()
		world = nil
		print("test")
	end

	return api
end

return {new = new}