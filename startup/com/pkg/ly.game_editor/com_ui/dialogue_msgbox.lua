--------------------------------------------------------
-- 通用 消息弹出确认框
--------------------------------------------------------

---@return ly.game_editor.dialogue_msgbox
local function create()
	local api = {} ---@class ly.game_editor.dialogue_msgbox

	function api.update()
	end
	
	return api	
end

return {create = create}