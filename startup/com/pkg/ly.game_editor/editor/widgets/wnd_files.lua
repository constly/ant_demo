--------------------------------------------------------
-- 窗口 文件列表
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
local function create(editor)
	---@class ly.game_editor.wnd_files
	local api = {}

	function api.draw(deltatime)
		ImGui.BeginGroup()
		local files = editor.files
		for i, v in ipairs(files.packages) do 
			ImGui.Text(tostring(v.name))
			ImGui.SameLineEx(200)
			ImGui.Text(tostring(v.path))
		end
		ImGui.EndGroup()
	end

	return api
end

return {create = create}