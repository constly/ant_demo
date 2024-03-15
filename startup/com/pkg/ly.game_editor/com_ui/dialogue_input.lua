--------------------------------------------------------
-- 通用 输入框
--------------------------------------------------------

---@return ly.game_editor.dialogue_input
local function create()
	local api = {} ---@class ly.game_editor.dialogue_input

	function api.update()
	end
	
	return api	
end

return {create = create}