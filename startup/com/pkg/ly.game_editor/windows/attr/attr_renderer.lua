--------------------------------------------------------
-- attr 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.attr.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.attr.renderer
	local api = {}
	local len_x = 380
	local content_x

	function api.set_data(data)
		data_hander.set_data(data)
		stack.set_data_handler(data_hander)
		stack.snapshoot(false)
	end

	function api.update()
		ImGui.SetCursorPos(10, 10)
		ImGui.Text("attr renderer")
	end

	return api
end 

return {new = new}