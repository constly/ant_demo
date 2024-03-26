--------------------------------------------------------
-- def 数据处理
--------------------------------------------------------
local function new()
	---@class ly.game_editor.def.handler
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	return api
end

return {new = new}