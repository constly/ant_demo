--------------------------------------------------------
-- attr 数据处理
--------------------------------------------------------
local dep = require 'dep'
local lib = dep.common.lib

---@class ly.game_editor.attr.data.attr
---@field id string 属性id 
---@field type string 属性类型(int/number/string等等)
---@field name string 属性名字(中文)
---@field desc string 描述
---@field category string 所属类别

---@class ly.game_editor.attr.data.region
---@field id string 作用域id
---@field attrs ly.game_editor.attr.data.attr[] 属性列表 

---@class ly.game_editor.attr.data 
---@field regions ly.game_editor.attr.data.region[] 作用域列表

local function new()
	---@class ly.game_editor.attr.handler
	---@field data ly.game_editor.attr.data
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	function api.to_string()
		local cache = api.data.cache
		api.data.cache = nil
		local content = dep.serialize.stringify(api.data)
		api.data.cache = cache
		return content
	end

	function api.set_data(data)
		if not data or type(data) ~= "table" or not data.regions then 
			data = {}
			data.regions = {}
		end 
		api.data = data
		if #data.regions > 0 then 
			api.set_selected_region(api.data.regions[1].id)
		end
	end

	---@return ly.game_editor.attr.data.region
	function api.add_region(id)
		---@type ly.game_editor.attr.data.region
		local region = {}
		region.id = id
		region.attrs = {}
		table.insert(api.data.regions, region)
		return region
	end 

	---@return ly.game_editor.attr.data.region
	function api.get_region(id)
		for i, v in ipairs(api.data.regions) do 
			if v.id == id then 
				return v
			end 
		end 
	end 

	---@return string
	function api.next_region_id(name)
		if not api.get_region(name) then return name end 
		for i = 1, 999 do 
			local temp = name .. i
			if not api.get_region(temp) then 
				return temp 
			end 
		end 
		return name
	end

	---@return ly.game_editor.attr.data.attr
	function api.get_attr(region_id, attr_id)
		local region = api.get_region(region_id)
		if not region then return end 
		for i, v in ipairs(region.attrs) do 
			if v.id == attr_id then 
				return v
			end
		end
	end

	---@return ly.game_editor.attr.data.attr
	function api.add_item(region_id, attr_id)
		local region = api.get_region(region_id)
		if not region then return end 
		---@type ly.game_editor.attr.data.attr
		local attr = {}
		attr.id = attr_id
		attr.type = "number"
		attr.name = "属性名"
		table.insert(region.attrs, attr)
		return attr
	end

	---@return string
	function api.next_attr_id(region_id, attr_id)
		local item = api.get_attr(region_id, attr_id)
		if not item then return attr_id end 
		for i = 1, 999 do 
			local temp = attr_id .. i
			if not api.get_attr(region_id, temp) then 
				return temp
			end
		end
		return attr_id
	end

	function api.set_selected_region(region_id)
		local cache = api.data.cache or {select_attr = {}}
		api.data.cache = cache
		cache.select_region = region_id
	end

	function api.set_selected_attr(region_id, attr_id)
		local cache = api.data.cache or {}
		api.data.cache = cache
		cache.select_region = region_id
		cache.select_attr[region_id] = attr_id
	end

	function api.get_selected_region_id()
		local cache = api.data.cache or {}
		return cache and cache.select_region
	end
	
	function api.get_selected_attr_id(region_id)
		region_id = region_id or api.get_selected_region_id()
		local cache = api.data.cache or {}
		return cache and cache.select_attr[region_id]
	end

	---@return ly.game_editor.attr.data.attr
	function api.get_selected_attr()
		local region = api.get_selected_region()
		if region then 
			return api.get_attr(region.id, api.get_selected_attr_id(region.id))
		end
	end

	---@return ly.game_editor.attr.data.region
	function api.get_selected_region()
		local id = api.get_selected_region_id()
		return id and api.get_region(id)
	end

	

	return api
end 

return {new = new}