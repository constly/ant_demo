--------------------------------------------------------
-- 窗口 文件列表
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.wnd_files
	local api = {}
	local selected_pkg 
	local icons = {}
	local function init()
		for i, name in ipairs({"ai", "csv", "folder", "ini", "map", "mod", "room"}) do 
			icons[name] = dep.assetmgr.resource(string.format("/pkg/ly.game_editor/assets/icon/icon_%s.texture", name), { compile = true })
		end
	end

	function api.draw(deltatime, line_y)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local left_x = 150
		ImGui.SetCursorPos(0, 0)
		ImGui.BeginChild("wnd_files_pkgs", left_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(5, 3)
		ImGui.BeginGroup()
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
			for i, name in ipairs(editor.tbParams.pkgs) do 
				if not selected_pkg then selected_pkg = name end
				if imgui_utils.draw_btn(name, selected_pkg == name, {size_x = left_x - 10} ) then 
					selected_pkg = name
				end
			end
			ImGui.PopStyleVar()
		ImGui.EndGroup()
		ImGui.EndChild()
		
		ImGui.SetCursorPos(left_x + 1, 3)
		imgui_utils.draw_btn("绘制路径")
		ImGui.SameLine()
		ImGui.Text(">")
		ImGui.SameLine()
		imgui_utils.draw_btn("绘制路径")
		ImGui.SameLine()
		ImGui.Text(">")
		ImGui.SameLine()
		imgui_utils.draw_btn("绘制路径")

		ImGui.SetCursorPos(left_x, line_y)
		ImGui.BeginChild("wnd_files_content", size_x - left_x, size_y - line_y, ImGui.ChildFlags({"Border"}))
		local tree = editor.files.resource_tree[selected_pkg]
		if tree then
			local tree = tree.tree
			for i, v in ipairs(tree.dirs) do 
				local path = v.r_path
				ImGui.Text("dir  " .. path)
				ImGui.SameLine()
				ImGui.Image(dep.textureman.texture_get(icons['ai'].id), 35, 35)
				if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
					ImGui.Text("这里显示Tips")
					ImGui.EndTooltip()
				end

			end
			for i, v in ipairs(tree.files) do 
				local path = v.r_path
				ImGui.Text("file " .. path)
			end
		end
		ImGui.EndChild()
	end

	init()
	return api
end

return {new = new}