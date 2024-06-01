local dep = require "dep" ---@type demo.dep

local function new()
	---@type ly.game_editor	
	local game_editor  	= import_package 'ly.game_editor'

	---@type ly.game_editor.create_params
	local tbParams = {}
	tbParams.module_name = "demo"
	tbParams.project_root = dep.common.path_def.project_root
	tbParams.pkgs = {"demo.res"}
	tbParams.theme_path = "/pkg/demo.res/themes/default.style"
	tbParams.workspace_path = "/pkg/demo.res/designer/space.work"
	tbParams.menus = {}
	return game_editor.create_editor(tbParams)
end

---@type ly.game_editor.editor
local editor = new()

function editor.default_draw(margin_x, margin_y)
	local ImGui = dep.ImGui
	local size_x, size_y = ImGui.GetContentRegionAvail()
	margin_x = margin_x or 30
	margin_y = margin_y or 30
	size_x = size_x - margin_x
	size_y = size_y - margin_y
	ImGui.SetCursorPos(margin_x * 0.5, margin_y * 0.5)
	ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 0, 0)
	ImGui.BeginChild("##child", size_x, size_y, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"})
		editor.draw()
	ImGui.EndChild()	
	ImGui.PopStyleVar()
end

return editor