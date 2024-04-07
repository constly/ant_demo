--------------------------------------------------------
-- attr 数据处理
--------------------------------------------------------
local dep = require 'dep'
local lib = dep.common.lib

---@class ly.game_editor.attr.data.style
---@field values map<string, table> 数据列表
---@field desc string 描述

---@class ly.game_editor.attr.data 
---@field name string 样式名字
---@field styles map<string, ly.game_editor.attr.data.style> 条目列表

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

	function api.set_data()
	end

	return api
end 

return {new = new}