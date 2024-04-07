--------------------------------------------------------
-- attr 剪切板处理
--------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.attr.handler
local function new(editor, data_hander)
	---@class ly.game_editor.attr.clipboard
	local api = {}

	function api.copy()
		
	end 

	function api.cut()
		
	end

	function api.paste()
		
	end

	function api.clear()
		ImGui.SetClipboardText("")
	end

	return api
end 

return {new = new}