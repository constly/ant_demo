---@class grid
---@field id number 唯一id
---@field pos_x number 坐标x
---@field pos_y number 坐标y
---@field tpl_id number 物件模板id


---@param map map 所属地图
local function new(map)

	---@class region
	---@field id number 唯一id
	---@field npcs npc[] 区域中npc列表
	---@field grids grid[] 区域中格子列表
	local api = {}
	api.npcs = {}
	api.grids = {}

	function api.init()

	end

	---@param gridTpl chess_grid_tpl
	function api.add_grid(x, y, z, gridTpl)
		---@type grid
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

	return api
end

return {new = new}