local grid_handler = require 'map.grid'

---@param map sims.server.map 所属地图
local function new(map)
	---@class sims.server.region
	---@field id number 唯一id
	---@field npcs sims.server.npc[] 区域中npc列表
	---@field grids sims.server.grid[] 区域中格子列表
	local api = {}
	api.npcs = {}
	api.grids = {}

	function api.init()

	end

	---@return sims.server.grid
	---@param gridTpl chess_grid_tpl
	function api.add_grid(x, y, z, gridTpl)
		local grid = grid_handler.new()
		grid.init(x, y, z, gridTpl)
		table.insert(api.grids, grid)
		return grid
	end

	---@param npc sims.server.npc
	function api.add_npc(npc)
		api.npcs[npc.id] = npc
	end 

	---@param npc sims.server.npc
	function api.remove_npc(npc)
		api.npcs[npc.id] = nil
	end

	---@class sims.server.region.sync
	---@field grids sims.server.grid.sync[]
	---@field npcs sims.server.npc.sync[]
	-- 得到同步数据
	---@return sims.server.region.sync
	function api.get_sync_data()
		local grids = {}
		for i, v in ipairs(api.grids) do 
			table.insert(grids, v.get_sync_data())
		end

		local npcs = {}
		for i, v in pairs(api.npcs) do 
			table.insert(npcs, v.get_sync_data())
		end
		return {grids = grids, npcs = npcs}
	end

	return api
end

return {new = new}