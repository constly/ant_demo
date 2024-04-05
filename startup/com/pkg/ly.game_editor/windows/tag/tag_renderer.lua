--------------------------------------------------------
-- tag 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.tag.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.tag.renderer
	local api = {}

	function api.set_data(data)
		stack.set_data_handler(data_hander)
		data_hander.set_data(data)
		stack.snapshoot(false)
	end

	function api.update(delta_time)
		ImGui.Text("aa")
	end

	return api
end 

return {new = new}