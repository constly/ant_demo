--------------------------------------------------------
-- goap 剪切板处理
--------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.goap.handler
local function new(editor, data_hander)
	---@class ly.game_editor.goap.clipboard
	local api = {}
	local last_cut_text

	function api.copy()
		last_cut_text = ""
		local v1, v2 = data_hander.selected_to_string() 
		if v1 == false then 
			ImGui.SetClipboardText("")
			return editor.msg_hints.show(v2, "error")
		else 
			v1 = v1 or ""
			ImGui.SetClipboardText(v1 or "")
			return true, v1
		end
	end 

	function api.cut()
		local ok, msg = api.copy()
		last_cut_text = ok and msg or ""
	end

	function api.paste()
		local str = ImGui.GetClipboardText()
		local is_cut
		if str == last_cut_text then 
			is_cut = true
	 	end
		return data_hander.string_to_selected(str, is_cut)
	end

	function api.clear()
		last_cut_text = ""
		ImGui.SetClipboardText("")
	end

	return api
end 

return {new = new}