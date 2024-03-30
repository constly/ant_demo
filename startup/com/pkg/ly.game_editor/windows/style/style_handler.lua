--------------------------------------------------------
-- style 数据处理
--------------------------------------------------------
local dep = require 'dep'
local lib = dep.common.lib

---@class ly.game_editor.style.data.style
---@field values map<string, table> 数据列表

---@class ly.game_editor.style.data 
---@field name string 样式名字
---@field styles map<string, ly.game_editor.style.data.style> 条目列表

local function new()
	---@class ly.game_editor.style.handler
	---@field data ly.game_editor.style.data
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	local all_styles		---@type ly.game_editor.style.all[] 
	local all_attr			---@type map<string, table>

	---@param _all_attr map<string, table>
	---@param _all_styles ly.game_editor.style.all[] 
	---@param data ly.game_editor.style.data
	function api.init(_all_styles, _all_attr, data)
		all_styles = _all_styles
		all_attr = _all_attr
		if data and data.styles then 
			api.data = data
		else 
			api.reset_all_styles()
		end
	end

	function api.to_string()
		local cache = api.data.cache
		api.data.cache = nil
		local content = dep.serialize.stringify(api.data)
		api.data.cache = cache
		return content
	end

	---@return ly.game_editor.style.data.style
	function api.get_style(key)
		return api.data.styles[key]
	end 

	--- 重置样式
	function api.reset_style(key)
		for _, category in ipairs(all_styles) do 
			for _, item in ipairs(category.list) do 
				if item.name == key then
					local tb_attr = all_attr[item.type]
					if tb_attr then 
						local tb = {}
						for _, attr in ipairs(tb_attr) do 
							local type, name, tip, enum, default = table.unpack(attr)
							tb[name] = lib.copy(default)
						end
						api.data.styles[item.name].values = tb
					end
					return
				end
			end
		end
	end

	--- 重置所有样式
	function api.reset_all_styles()
		local data = api.data
		if not data.styles then 
			data.styles = {} 
		end  
		
		data.styles = {} 
		for _, category in ipairs(all_styles) do 
			for _, item in ipairs(category.list) do 
				local tb_attr = all_attr[item.type]
				if tb_attr then 
					local tb = {}
					for _, attr in ipairs(tb_attr) do 
						local type, name, tip, enum, default = table.unpack(attr)
						tb[name] = lib.copy(default)
					end
					data.styles[item.name] = {values = tb}
				else 
					log.warn("类型未注册: " .. item.type)
				end
			end
		end
	end

	---@return ly.game_editor.style.data.style 得到当前选中的style名字
	function api.get_selected()
		local cache = api.data.cache
		return cache and cache.selected
	end 

	---@return boolean 设置当前选中的style名字
	function api.set_selected(name)
		local cache = api.data.cache or {}
		api.data.cache = cache
		if cache.selected ~= name then
			cache.selected = name
			return true
		end 
	end 


	return api
end

return {new = new}