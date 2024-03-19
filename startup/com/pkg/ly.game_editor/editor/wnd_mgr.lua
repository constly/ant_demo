--------------------------------------------------------
-- 窗口管理
--------------------------------------------------------

local function new()
	local api = {}  ---@class ly.game_editor.wnd_mgr

	---得到tab对应的window
	---@param tab ly.game_editor.tab_item
	function api.get_wnd_by_tab(tab)
		--tab.path
	end

	return api
end

return {new = new}