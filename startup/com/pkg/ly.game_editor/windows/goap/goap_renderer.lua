--------------------------------------------------------
-- goap 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.goap.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.goap.renderer
	local api = {}

	function api.set_data(data)
		stack.set_data_handler(data_hander)
		data_hander.set_data(data)
		stack.snapshoot(false)
	end

	function api.update(delta_time)
		ImGui.SetCursorPos(10, 10)
		ImGui.Text("goap")
	end

	return api
end


return {new = new}