local common = import_package 'ly.common'

-- 图数据处理器
local function new ()
	---@class chess_data_handler
	---@field data chess_map_tpl 棋盘模板id
	---@field stack_version number 堆栈版本号,当堆栈版本号发生变化时，需要刷新编辑器
	---@field isModify boolean 数据是否有变化
	---@field tb_cache_object_def table<int, chess_object_tpl> 物件模板列表
	---@field max_object_size_x number 最大物件的宽
	---@field max_object_size_y number 最大物件的高
	local handler = {
		data = {},
		stack_version = 0,
		isModify = false,
		tb_cache_object_def = {}
	}

	local DATA_VERSION = 1

	---@param _data chess_map_tpl
	function handler.init(_data)
		local data = common.lib.copy(_data) or {} ---@type chess_map_tpl
		handler.data = data
		if not data.regions then 
			data.next_id = 0;
			data.regions = {}
			data.regions[1] = handler.create_region()
			data.show_ground = true
			data.region_index = 1
			data.path_def = ""
		end
		data.version = DATA_VERSION
		data.cache = {selects = {}, invisibles = {}}
	end

	function handler.refresh_path_def(tb_objects)
		handler.max_object_size_x = 1
		handler.max_object_size_y = 1
		handler.tb_cache_object_def = {}
		for _, v in ipairs(tb_objects or {}) do 
			handler.tb_cache_object_def[v.id] = v
			if v.size then
				handler.max_object_size_x = math.max(handler.max_object_size_x, v.size.x or 1)
				handler.max_object_size_y = math.max(handler.max_object_size_y, v.size.y or 1)
			end
		end

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
		region.min = {x = -2, y = -2}
		region.max = {x = 2, y = 2}
		region.id = handler.next_id()
		region.layers = {}
		table.insert(region.layers, handler.create_region_layer(-1, true))
		table.insert(region.layers, handler.create_region_layer(0, false))
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
		layer.id = handler.next_id()
		layer.height = height
		layer.active = active;
		layer.grids = {}
		return layer;
	end

	--- 创建格子
	---@param tplId number 物件模板id
	---@return chess_grid_tpl
	function handler.create_grid_tpl(tplId)
		---@type chess_grid_tpl 
		local grid = {}
		grid.id = handler.next_id()
		grid.tpl = tplId
		return grid;
	end

	--- 得到当前选中的区域
	---@return chess_map_region_tpl 
	function handler.cur_region()
		local data = handler.data
		return data.regions[data.region_index]
	end

	--- 清空所有选择的层级
	---@param region chess_map_region_tpl
	function handler.clear_all_selected_layer(region)
		for i, v in ipairs(region.layers) do 
			v.active = false
		end
	end

	--- 查找layer 
	---@param region chess_map_region_tpl
	function handler.get_layer_by_id(region, id)
		for i, v in ipairs(region.layers) do 
			if v.id == id then 
				return v 
			end
		end
	end

	--- 检测点到了哪个物件
	---@param layer chess_map_region_layer_tpl 
	---@param x number 格子x位置
	---@param y number 格子y位置
	---@return chess_grid_tpl
	function handler.get_clicked_object(layer, x, y)
		for gridId, v in pairs(layer.grids) do 
			local pos_x, pos_y = handler.grid_id_to_grid_pos(gridId)
			if x >= pos_x and y >= pos_y then 
				local check_end_x = pos_x + handler.max_object_size_x - 1  -- 先做大概筛选
				local check_end_y = pos_y + handler.max_object_size_y - 1
				if x <= check_end_x and y <= check_end_y then 
					local tpl = handler.get_object_tpl(v.tpl)
					check_end_x = pos_x + tpl.size.x - 1
					check_end_y = pos_y + tpl.size.y - 1
					if x <= check_end_x and y <= check_end_y then 
						return v, gridId
					end
				end
			end
		end
	end
	
	--- 得到最顶层的层级	
	---@param region chess_map_region_tpl
	---@return chess_map_region_layer_tpl 
	function handler.get_top_active_layer(region)
		for i = #region.layers, 1, -1 do 
			local tpl = region.layers[i]
			if tpl.active then 
				return tpl
			end
		end
	end

	--- 将格子坐标转换为格子id
	---@param pos_x number 格子坐标x
	---@param pos_y number 格子坐标y
	---@return number 格子id
	function handler.grid_pos_to_grid_id(pos_x, pos_y)
		return string.format("%d_%d", pos_x, pos_y) 
	end

	--- 将格子id转换为格子坐标
	---@return number, number pos_x,pos_y
	function handler.grid_id_to_grid_pos(gridId)
		local pos = string.find(gridId, "_")
		if pos then
			local x = string.sub(gridId, 1, pos - 1)
			local y = string.sub(gridId, pos + 1)
			return tonumber(x), tonumber(y)
		end
		return 0, 0
	end

	--- 得到物件模板
	---@param tplId number 模板id
	---@return chess_object_tpl 模板对象
	function handler.get_object_tpl(tplId)
		return handler.tb_cache_object_def[tplId]
	end

	-- 是否配置有数据定义文件
	function handler.has_path_def()
		return handler.data.path_def and handler.data.path_def ~= ""
	end

	-------------------------------------------------------------------
	-- 选中相关
	-------------------------------------------------------------------
	--- 添加选中的物件
	---@param region chess_map_region_tpl
	---@param type string ground or object 
	---@param id number|string id
	---@param layerId number 层级id
	function handler.add_selected(region, type, id, layerId)
		if handler.has_selected(region, type, id, layerId) then return end

		local _cache = handler.data.cache ---@type chess_map_tpl_cache
		local list = _cache.selects[region.id] or {}
		_cache.selects[region.id] = list
		table.insert(list, {type = type, id = id, layer = layerId});
	end

	-- 是否选中
	---@param region chess_map_region_tpl
	---@param type string ground or object 
	---@param id number id
	---@param layerId number 层级id
	function handler.has_selected(region, type, id, layerId)
		local list = handler.data.cache.selects[region.id] or {}
		for i, v in ipairs(list) do 
			if v.type == type and v.id == id and v.layer == layerId then 
				return true;
			end
		end
	end

	-- 得到首个选中的
	---@param region chess_map_region_tpl
	---@return string, string, number
	function handler.get_first_selected(region)
		local list = handler.data.cache.selects[region.id] or {}
		for i, v in ipairs(list) do 
			local layer = handler.get_layer_by_id(region, v.layer)
			if layer and layer.active then 
				return v.type, v.id, v.layer
			end
		end
	end

	-- 是不是多选
	---@param region chess_map_region_tpl
	function handler.is_multi_selected(region)
		local list = handler.data.cache.selects[region.id] or {}
		return #list > 1
	end

	--- 得到格子数据
	---@param region chess_map_region_tpl
	function handler.get_grid_data(region, layerId, gridId)
		local layer = handler.get_layer_by_id(region, layerId)
		if layer then 
			return layer.grids[gridId]
		end
	end

	--- 得到格子数据
	function handler.get_grid_data_by_uid(region, layerId, uid)
		local layer = handler.get_layer_by_id(region, layerId)
		if layer then 
			for gridId, v in pairs(layer.grids) do 
				if v.id == uid then 
					return v, gridId
				end
			end
		end
	end

	-- 清空所有选中的物件
	function handler.clear_selected(region)
		handler.data.cache.selects[region.id] = {}
	end

	-------------------------------------------------------------------
	-- invisibles（不可见维护）
	-------------------------------------------------------------------
	---@param region chess_map_region_tpl
	---@param uid number 唯一id
	function handler.add_invisible(region, uid)
		local cache = handler.data.cache
		local list = cache.invisibles[region.id] or {}
		cache.invisibles[region.id] = list
		list[uid] = true
	end

	---@param region chess_map_region_tpl
	---@param uid number 唯一id
	function handler.is_invisible(region, uid)
		local list = handler.data.cache.invisibles[region.id] or {}
		return list[uid] == true
	end

	---@param region chess_map_region_tpl
	---@param uid number 唯一id
	function handler.remove_invisible(region, uid)
		local list = handler.data.cache.invisibles[region.id] or {}
		list[uid] = nil
	end

	--- 得到不可见数量
	---@param region chess_map_region_tpl
	function handler.get_invisible_count(region)
		local list = handler.data.cache.invisibles[region.id] or {}
		local n = 0;
		for _, _ in pairs(list) do 
			n = n + 1
		end 
		return n;
	end

	---@param region chess_map_region_tpl
	function handler.clear_invisible(region)
		handler.data.cache.invisibles[region.id] = {}
	end
	
	return handler
end 

return {new = new}