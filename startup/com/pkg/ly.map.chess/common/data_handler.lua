
-- 图数据处理器
local create = function()
	---@class chess_data_handler
	---@field data chess_map_tpl 棋盘模板id
	---@field stack_version number 堆栈版本号,当堆栈版本号发生变化时，需要刷新编辑器
	---@field isModify boolean 数据是否有变化
	local handler = {
		data = {},
		stack_version = 0,
		isModify = false,
	}

	---@param args chess_editor_create_args
	function handler.init(args)
		local data = {} ---@type chess_map_tpl
		handler.data = data

		data.next_id = 0;
		data.regions = {}
		data.regions[1] = handler.create_region()
		data.region_index = 1
	end

	function handler.next_id()
		local data = handler.data 
		data.next_id = data.next_id + 1; 
		return data.next_id
	end

	---@return chess_map_region_tpl
	function handler.create_region() 
		---@type chess_map_region_tpl
		local region = {}
		region.min = {x = -5, y = -5}
		region.max = {x = 5, y = 5}
		region.id = handler.next_id()
		region.layers = {}
		table.insert(region.layers, handler.create_region_layer(-1, false))
		table.insert(region.layers, handler.create_region_layer(0, true))
		table.insert(region.layers, handler.create_region_layer(1, false))
		return region
	end

	--- 创建层级
	---@return chess_map_region_layer_tpl 
	---@param height number | nil 高度,如果为nil就表示为逻辑层级
	---@param active boolean 是否激活
	function handler.create_region_layer(height, active)
		---@type chess_map_region_layer_tpl 
		local layer = {}
		layer.height = height
		layer.active = active;
		layer.grids = {}
		return layer;
	end

	--- 得到当前选中的区域
	---@return chess_map_region_tpl 
	function handler.cur_region()
		local data = handler.data
		return data.regions[data.region_index]
	end
	
	--- 得到下个层级的高度
	---@param region chess_map_region_tpl
	---@param from number 起始位置
	---@param dir number 方向
	function handler.get_next_height(region, from, dir)
		local layer = region.layers[from]
		if not layer then 
			return 0;
		end
		local height = layer.height + dir
		return math.ceil(height)
	end

	--- 得到逻辑层级的高度
	---@param region chess_map_region_tpl
	---@param layer chess_map_region_layer_tpl
	function handler.get_logic_layer_height(region, layer)
		if layer.height then return layer.height end 
		local idx = handler.get_layer_index(region, layer)
		if not idx then return "?" end
		for i = idx, 1, -1 do 
			local l = region.layers[i]
			if l.height then 
				return l.height
			end
		end
		return "?"
	end

	--- 得到层级在数组中的索引
	---@param region chess_map_region_tpl
	---@param layer chess_map_region_layer_tpl
	function handler.get_layer_index(region, layer)
		for i, v in ipairs(region.layers) do 
			if v == layer then 
				return i
			end
		end
	end

	return handler
end 

return {create = create}