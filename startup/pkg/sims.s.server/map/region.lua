---@class sims.server.grid
---@field id number 唯一id
---@field pos_x number 坐标x
---@field pos_y number 坐标y
---@field tpl_id number 物件模板id


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

	---@param gridTpl chess_grid_tpl
	function api.add_grid(x, y, z, gridTpl)
		---@type sims.server.grid
		local grid = {}
		grid.id = gridTpl.id
		grid.tpl_id = gridTpl.tpl
		grid.pos_x = x 
		grid.pos_y = y 
		grid.pos_z = z 
		if gridTpl.rotate and gridTpl.rotate ~= 0 then 
			grid.rotate = gridTpl.rotate
		end
		if gridTpl.hidden then 
			grid.hidden = gridTpl.hidden
		end
		table.insert(api.grids, grid)
	end

	---@param npc sims.server.npc
	function api.add_npc(npc)
		table.insert(api.npcs, npc)
	end 

	---@param npc sims.server.npc
	function api.remove_npc(npc)
		for i, v in ipairs(api.npcs) do 
			if v == npc then 
				return table.remove(api.npcs, i)
			end
		end
	end

	---@class sims.server.region.sync
	---@field grids sims.server.grid[]
	---@field npcs sims.server.npc.sync.data[]
	-- 得到同步数据
	---@return sims.server.region.sync
	function api.get_sync_data()
		local npcs = {}
		for i, v in pairs(api.npcs) do 
			table.insert(npcs, v.get_sync_data())
		end
		return {grids = api.grids, npcs = npcs}
	end

	return api
end

return {new = new}