--------------------------------------------------------
--- sesctions 数据管理
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param stack common_data_stack
---@param goap_handler ly.game_editor.goap.handler
local function new(editor, stack, goap_handler)
	---@class ly.game_editor.goap.body.sections
	local api = {}

	---@param node ly.game_editor.goap.node
	function api.init(node)
		
	end

	function api.draw(node, delta_time, size_x)
		ImGui.Text("sections")
	end

	return api
end

return {new = new}