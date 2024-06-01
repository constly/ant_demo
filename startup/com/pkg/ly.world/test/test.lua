---------------------------------------------------------
--- 1. 测试寻路功能
--- 2. 测试寻路性能
---------------------------------------------------------

local world_impl = require 'ly.world.impl'

---@type ly.world.main
local main = require 'main'

local gridDef = main.get_grid_def()
local walkDef = main.get_walk_type()

---@type ly.common
local common = import_package 'ly.common'

local function new()
	---@class ly.astar.test
	local api = {}

	function api.run()
		---@type ly.world.c_world 
		local world = world_impl.CreateWorld();

		for i = 1, 10 do 
			world:SetGridData(i, 0, 1, 1, 1, 1, gridDef.Under_Ground)
		end
		world:Update()
		assert(world:GetGridType(0, 0, 1) == gridDef.Wall, "检查地形是 墙表面")		
		assert(world:GetGridType(1, 0, 1) == gridDef.Under_Ground, "检查地形是 地下")
		assert(world:GetGridType(1, -1, 1) == gridDef.Ceiling, "检查地形是 天花板")
		assert(world:GetGridType(1, 1, 1) == gridDef.Ground, "检查地形是 地表面")

		local start = {1, 1, 1}
		local dest = {7, 1, 1}
		local bodySize = 1
		local walkType = walkDef.Ground
	 	local tb = world:FindPath(start[1], start[2], start[3], dest[1], dest[2], dest[3], bodySize, walkType)

		assert(tb, "寻路失败")
		for i, v in ipairs(tb) do 
			print("node" .. i, v[1], v[2], v[3])
		end
		--common.lib.dump(tb)

		world:Destroy()
		world = nil
		print("test complete.")
	end

	return api
end

return {new = new}