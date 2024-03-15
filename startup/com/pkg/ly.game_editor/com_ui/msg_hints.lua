--------------------------------------------------------
-- 通用 消息提示框
--------------------------------------------------------

---@return ly.game_editor.msg_hints
local function create()
	local api = {} ---@class ly.game_editor.msg_hints

	function api.update()
	end

	return api	
end

return {create = create}