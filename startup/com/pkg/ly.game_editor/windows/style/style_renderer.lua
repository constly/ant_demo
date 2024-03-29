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

	---@type ly.game_editor.style.all[] 
	local all_styles = require 'editor.style' .get_styles()

	function api.set_data()
	end

	function api.update(delta_time)
		for i, category in ipairs(all_styles) do 
			for j, item in ipairs(category.list) do 
				ImGui.Text(string.format("%s - %s - %s - %s", category.name, item.name, item.type, item.desc))
			end 
		end 
	end

	return api
end


return {new = new}