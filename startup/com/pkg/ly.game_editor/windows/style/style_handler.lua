--------------------------------------------------------
-- style 数据处理
--------------------------------------------------------
local dep = require 'dep'
---@class ly.game_editor.style.data
---@field name string

local function new()
	---@class ly.game_editor.style.handler
	---@field data ly.game_editor.style.data
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	return api
end

return {new = new}