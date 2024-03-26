local function new()
	---@class ly.game_editor.csv.handler
	local handler = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	return handler
end

return {new = new}