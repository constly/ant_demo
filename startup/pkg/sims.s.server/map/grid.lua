---@class sims.server.grid.sync  格子同步数据
---@field id number 唯一id
---@field pos_x number 坐标x
---@field pos_y number 坐标y
---@field pos_z number 坐标y
---@field tpl_id number 物件模板id
---@field rotate number 旋转
---@field hidden boolean 是否隐藏


---@class sims.server.grid		格子数据
---@field id number 唯一id
---@field pos_x number 坐标x
---@field pos_y number 坐标y
---@field pos_z number 坐标y
---@field tpl_id number 物件模板id
---@field tpl chess_grid_tpl 格子模板
---@field rotate number 旋转
---@field hidden boolean 是否隐藏

---
local function new()
	---@type sims.server.grid
	local api = {}

	---@param gridTpl chess_grid_tpl
	function api.init(x, y, z, gridTpl)
		api.id = gridTpl.id
		api.tpl_id = gridTpl.tpl
		api.tpl = gridTpl
		api.pos_x = x 
		api.pos_y = y 
		api.pos_z = z 
		if gridTpl.rotate and gridTpl.rotate ~= 0 then 
			api.rotate = gridTpl.rotate
		end
		if gridTpl.hidden then 
			api.hidden = gridTpl.hidden
		end
	end

	---@return sims.server.grid.sync
	function api.get_sync_data()
		---@type sims.server.grid.sync
		local tb = {}
		tb.id = api.id 
		tb.tpl_id = api.tpl_id
		tb.pos_x = api.pos_x
		tb.pos_y = api.pos_y
		tb.pos_z = api.pos_z
		tb.rotate = api.rotate
		return tb
	end

	return api
end

return {new = new}