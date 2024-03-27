--------------------------------------------------------
-- ini 数据处理
--------------------------------------------------------

local dep = require 'dep'

---@class ly.game_editor.ini.item
---@field type string	数据类型
---@field key string 数据key
---@field value string 数据值
---@field desc string 描述

---@class ly.game_editor.ini.region 
---@field name string region名字
---@field desc string 描述
---@field items ly.game_editor.ini.item[] 条目列表

local function new()
	---@class ly.game_editor.ini.handler
	---@field data ly.game_editor.ini.region[]
	local api = {
		data = {}, 		
		stack_version = 0,
		isModify = false,
	}

	function api.to_string()
		local cache = api.data.cache
		api.data.cache = nil
		local content = dep.serialize.stringify(api.data)
		api.data.cache = cache
		return content
	end

	function api.has_item(region, key)
		return api.get_item(region, key) ~= nil
	end

	function api.has_region(region)
		return api.get_region(region) ~= nil
	end

	---@return ly.game_editor.ini.item
	function api.get_item(region, key)
		if not region or not key then return end
		local region = api.get_region(region) or {}
		for i, v in ipairs(region.items) do 
			if v.key == key then 
				return v
			end
		end
	end

	---@return ly.game_editor.ini.region
	function api.get_region(name)
		for i, v in ipairs(api.data) do 
			if v.name == name then 
				return v, i
			end
		end
	end

	---@return ly.game_editor.ini.region
	function api.add_region(name)
		if api.has_region(name) then return end 
		local region = {}
		region.name = name
		region.desc = ""
		region.items = {}
		table.insert(api.data, region)
		return region
	end

	---@return ly.game_editor.ini.item
	function api.add_item(region, key, index)
		if not key or api.has_item(region, key) then return end 

		local region = api.get_region(region)
		local data = {}
		data.key = key 
		data.value = ""
		data.type = "string"
		if index then 
			table.insert(region.items, index, data)
		else 
			table.insert(region.items, data)
		end
		return data
	end

	---@return ly.game_editor.ini.item
	function api.clone_item(region_name, key)
		local region = api.get_region(region_name)
		if not region then return end 
		for i, item in ipairs(region.items) do 
			if item.key == key then 
				local new = dep.common.lib.copy(item)
				new.key = api.gen_next_item_name(region_name, item.key)
				table.insert(region.items, i + 1, new)	
				return new
			end
		end
	end

	function api.delte_region(region)
		for i, v in ipairs(api.data) do 
			if v.name == region then
				table.remove(api.data, i)
				return true
			end
		end
	end

	---@return ly.game_editor.ini.region
	function api.clone_region(region_name, index)
		local region = api.get_region(region_name)
		local new = dep.common.lib.copy(region)
		new.name = api.gen_next_region_name(region_name)
		table.insert(api.data, index, new);
		return new
	end

	function api.delte_item(region_name, key)
		local region = api.get_region(region_name)
		if not region then return end 
		for i, v in ipairs(region.items) do 
			if v.key == key then 
				table.remove(region.items, i)
				return true, i
			end
		end
	end

	function api.gen_next_region_name(region_name)
		local find = {}
		for i, v in ipairs(api.data) do 
			find[v.name] = true
		end

		if not find[region_name] then return region_name end 
		for i = 1, 9999 do 
			local name = region_name .. i
			if not find[name] then 
				return name
			end
		end
		return region_name
	end

	function api.gen_next_item_name(region_name, default_key)
		local region = api.get_region(region_name)
		if not region then return end 
		local find = {}
		for i, v in ipairs(region.items) do 
			find[v.key] = true
		end
		if not find[default_key] then return default_key end 
		for i = 1, 9999 do 
			local key = default_key .. i
			if not find[key] then 
				return key
			end
		end
		return default_key
	end

	function api.set_selected(region_name, key)
		local old_region, old_key = api.get_selected()
		if old_region == region_name and old_key == key then 
			return
		end
		local cache = api.data.cache or {}
		api.data.cache = cache
		cache.selected = {region = region_name, key = key}
		return true
	end

	function api.get_selected()
		local cache = api.data.cache
		if cache and cache.selected then 
			return cache.selected.region, cache.selected.key
		end
	end

	---@return ly.game_editor.ini.region
	function api.get_selected_region()
		local region_name = api.get_selected()
		return region_name and api.get_region(region_name)
	end

	---@return ly.game_editor.ini.item
	function api.get_selected_item()
		local region_name, key = api.get_selected()
		return api.get_item(region_name, key)
	end

	function api.drag_region(fromRegion, toRegion)
		local region1, index = api.get_region(fromRegion)
		local region2 = api.get_region(toRegion)
		if not region1 or not region2 then return end 
		api.delte_region(fromRegion)
		for i, v in ipairs(api.data) do 
			if v.name == toRegion then 
				table.insert(api.data, (i == index) and (i + 1) or i, region1)
				return true
			end
		end
	end

	function api.drag_item(fromRegion, fromKey, toRegion, toKey)
		local region1 = api.get_region(fromRegion)
		local region2 = api.get_region(toRegion)
		local item = api.get_item(fromRegion, fromKey)
		if not region1 or not region2 or not item then return end 
		if region1 == region2 then 
			local ret, index = api.delte_item(fromRegion, fromKey)
			for i, v in ipairs(region1.items) do 
				if v.key == toKey then 		
					table.insert(region1.items, (index == i) and (i + 1) or (i), item)
					return true
				end
			end
		else
			if api.get_item(toRegion, fromKey) then 
				return "当前region已经存在" .. fromKey
			end
			api.delte_item(fromRegion, fromKey)
			for i, v in ipairs(region2.items) do 
				if v.key == toKey then 
					table.insert(region2.items, i + 1, item)
					return true
				end
			end
		end
	end

	return api
end

return {new = new}