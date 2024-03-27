--------------------------------------------------------
-- def 数据处理
--------------------------------------------------------
local dep = require 'dep'

local function new()
	---@class ly.game_editor.def.handler
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

	return api
end

return {new = new}