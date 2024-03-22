--------------------------------------------------------
-- 窗口 文件列表
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils
local imgui_styles = dep.common.imgui_styles
local lib = dep.common.lib

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.wnd_files
	local api = {}
	local selected_pkg 
	local icons = {}
	local selected_file = ""
	local view_path

	local function init()
		for i, name in ipairs({"ai", "csv", "folder", "ini", "map", "mod", "room"}) do 
			icons[name] = dep.assetmgr.resource(string.format("/pkg/ly.game_editor/assets/icon/icon_%s.texture", name), { compile = true })
		end
	end

	local function set_selected_file(value)
		if selected_file ~= value then 
			selected_file = value
		end
	end

	local function set_view_path(path)
		if path == "" then 
			path = nil 
		end
		view_path = path
		set_selected_file()
	end

	local function set_selected_pkg(value)
		if value == selected_pkg then return end 
		selected_pkg = value
		set_view_path()
	end

	local function draw_pkgs(size_x)
		ImGui.SetCursorPos(5, 3)
		ImGui.BeginGroup()
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
		for i, name in ipairs(editor.tbParams.pkgs) do 
			if not selected_pkg then set_selected_pkg(name) end
			if imgui_utils.draw_btn(name, selected_pkg == name, {size_x = size_x - 10} ) then 
				set_selected_pkg(name)
			end
		end
		ImGui.PopStyleVar()
		ImGui.EndGroup()
	end

	local function draw_view_path()
		local arr = lib.split(view_path, "/")
		table.insert(arr, 1, "root")
		for i, v in ipairs(arr) do 
			local label = string.format("%s##btn_files_dir_%d", v, i)
			if imgui_utils.draw_btn(label) then 
				set_view_path(table.concat(arr, "/", 2, i))
			end
			ImGui.SameLine()
			if i < #arr then 
				ImGui.Text(">")
				ImGui.SameLine()
			end
		end
	end

	local function draw_file_menu(ext, display, isDir, path)
		if ImGui.BeginPopupContextItem() then
			set_selected_file(display)
			
			if ImGui.MenuItem("改 名") then
			end
			if ImGui.MenuItem("删 除") then
			end
			if ImGui.MenuItem("克 隆") then
			end
			if ImGui.MenuItem("收 藏") then
				editor.portal.add(selected_pkg .. "/" .. path)
			end
			if ImGui.MenuItem("在文件浏览器中打开") then
			end
			ImGui.EndPopup()
		end
	end

	function api.draw(deltatime, line_y)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local left_x = 150
		ImGui.SetCursorPos(0, 0)
		ImGui.BeginChild("wnd_files_pkgs", left_x, size_y, ImGui.ChildFlags({"Border"}))
		draw_pkgs(left_x)
		ImGui.EndChild()
		
		ImGui.SetCursorPos(left_x + 1, 3)
		draw_view_path()

		ImGui.SetCursorPos(left_x, line_y)
		ImGui.BeginChild("wnd_files_content", size_x - left_x, size_y - line_y, ImGui.ChildFlags({"Border"}))
		local root = editor.files.resource_tree[selected_pkg]
		local tree = editor.files.find_tree_by_path(root, view_path)
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 15, 10)
        ImGui.PushStyleVarImVec2(ImGui.StyleVar.ItemSpacing, 10, 5)
		if tree then
			local size_x, size_y = ImGui.GetContentRegionAvail()
			local start_x = 5
			local pos = {x = start_x, y = 8}
			local cell<const> = {x = 80, y = 67}
			local texSize = {x = 35, y = 35}
			local maskSize = {x = 65, y = 40}
			local btnSize = {x = 70, y = 22}
			local index = 0
			
			local function draw_file(ext, name, display, isDir, path)
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
						set_selected_file(display)
					end
					if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
						if isDir then 
							set_view_path(view_path and (view_path .. "/" .. name) or name)
						else

						end
					end
				end
				draw_file_menu(ext, display, isDir, path)
				do
					ImGui.SetCursorPos(pos.x + 5, pos.y + 35)
					local style<close> = imgui_styles.use(display == selected_file and imgui_styles.btn_transparency_center_selected or imgui_styles.btn_transparency_center)
					local label = string.format("%s##btn_file_node_%s", display, index)
					if ImGui.ButtonEx(label, btnSize.x, btnSize.y) then 
						set_selected_file(display)
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
				draw_file('folder', v.name, v.name, true, v.r_path)
			end
			for i, v in ipairs(tree.files) do 
				draw_file(v.ext, v.name, v.short_name, false, v.r_path)
			end
			-- for i = 1, 10 do 
			-- 	draw_file('folder', "文件名字")
			-- end
		end
		ImGui.PopStyleVarEx(2)
		ImGui.EndChild()
	end

	function api.get_icon_id_by_ext(ext)
		local icon = icons[ext]
		return icon and icon.id 
	end

	init()
	return api
end

return {new = new}