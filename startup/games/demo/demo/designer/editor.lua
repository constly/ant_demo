local dep = require "dep" ---@type demo.dep

local function new()
	---@type ly.game_editor	
	local game_editor  	= import_package 'ly.game_editor'

	---@type ly.game_editor.create_params
	local tbParams = {}
	tbParams.module_name = "demo"
	tbParams.project_root = dep.common.path_def.project_root
	tbParams.pkgs = {"demo.res"}
	tbParams.theme_path = "demo.res/themes/default.style"
	tbParams.workspace_path = "/pkg/demo.res/designer/space.work"
	tbParams.menus = {}
	return game_editor.create_editor(tbParams)
end

---@type ly.game_editor.editor
local editor = new()

function editor.default_draw()
	local ImGui = dep.ImGui
	local size_x, size_y = ImGui.GetContentRegionAvail()
	size_x = size_x - 50
	size_y = size_y - 50
	ImGui.SetCursorPos(20, 30)
	ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 0, 0)
	ImGui.BeginChild("##child", size_x, size_y, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"})
		editor.draw()
	ImGui.EndChild()	
	ImGui.PopStyleVar()
end

return editor