--------------------------------------------------------
-- style 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local imgui_utils = dep.common.imgui_utils
local imgui_styles = dep.common.imgui_styles
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.style.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.style.renderer
	local api = {}
	local len_x = 350
	local content_x

	function api.set_data()
	end

	function api.update(delta_time)
	end

	return api
end


return {new = new}