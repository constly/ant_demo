--------------------------------------------------------
-- 窗口 文件列表
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils
local imgui_styles = dep.common.imgui_styles

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.wnd_files
	local api = {}
	local selected_pkg 
	local icons = {}
	local selected_file = 0

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

			local get_name = function(idx)
				if idx == 1 then return "名字"
				elseif idx == 2 then return "文件名字"
				elseif idx == 3 then return "很长的文件名字呀呀呀呀"
				elseif idx == 4 then return "n"
				else return "默认名字是" end 
			end

			local size_x, size_y = ImGui.GetContentRegionAvail()
			local start_x = 5
			local pos = {x = start_x, y = 8}
			local cell<const> = {x = 80, y = 67}
			local texSize = {x = 35, y = 35}
			local maskSize = {x = 65, y = 40}
			local btnSize = {x = 70, y = 22}
			local index = 0
			
			local function draw_file(ext, name)
				index = index + 1
				local temp = {x = pos.x + cell.x * 0.5, y = pos.y}
				ImGui.SetCursorPos(temp.x - texSize.x * 0.5, temp.y)
				ImGui.Image(dep.textureman.texture_get(icons[ext].id), texSize.x, texSize.y)
				
				do
					ImGui.SetCursorPos(temp.x - maskSize.x * 0.5, temp.y)
					local label = "##btn_file_node_mask_" .. index
					local style<close> = imgui_styles.use(imgui_styles.btn_transparency_center)
					if ImGui.ButtonEx(label, maskSize.x, maskSize.y) then 
						print("click")
						selected_file = index
					end
					if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
						print("打开文件，或者是目录")
					end
				end

				-- 这里处理右键菜单

				do
					ImGui.SetCursorPos(pos.x + 5, pos.y + 35)
					local style<close> = imgui_styles.use(index == selected_file and imgui_styles.btn_transparency_center_selected or imgui_styles.btn_transparency_center)
					local label = string.format("%s##btn_file_node_%s", name, index)
					if ImGui.ButtonEx(label, btnSize.x, btnSize.y) then 
						selected_file = index
					end
				end

				if pos.x + cell.x * 2 >= size_x + 10 then 
					pos.y = pos.y + cell.y 
					pos.x = start_x
				else 
					pos.x = pos.x + cell.x
				end
			end
			for i, v in ipairs(tree.dirs) do 
				draw_file('folder', v.name)
			end
			for i, v in ipairs(tree.files) do 
				local path = v.r_path
				draw_file(v.ext, v.name)
			end
			-- for i = 1, 10 do 
			-- 	draw_file('folder', "文件名字")
			-- end
		end
		ImGui.EndChild()
	end

	init()
	return api
end

return {new = new}