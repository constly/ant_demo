--------------------------------------------------------
-- 窗口 文件列表
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ImGui = dep.ImGui
local imgui_styles = dep.common.imgui_styles
local imgui_utils = dep.common.imgui_utils
local lib = dep.common.lib
local user_data = dep.common.user_data
local lfs       = require "bee.filesystem"

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.wnd_files
	local api = {}
	local selected_pkg 
	local icons = {}
	local selected_file = ""
	local view_path
	local is_window_active
	local tb_new_file_desc = {}
	local drop_menu_name = "drop_menu_name"
	local need_open_drop_menu = false
	local drop_from, drop_to

	local function init()
		tb_new_file_desc = {
			{"ini", 	"ini 配置文件"},
			{"txt", 	"txt 表格文件"},
			{"map", 	"map 地图文件"},
			{"room", 	"room 房间文件"},
			{"tag", 	"tag 标签定义文件"},
			{"fsm", 	"fsm 状态机文化"},
			{"goap", 	"goap 行为定义文件"},
			{"attr", 	"attr 属性定义文件"},
			{"style", 	"style 编辑器样式文件"},
			{"def", 	"def 数据定义文件"},
		}
		for i, name in ipairs({"ai", "txt", "csv", "folder", "ini", "map", "mod", "room", "def", "fsm", "tag", "goap", "attr", "style"}) do 
			icons[name] = dep.assetmgr.resource(string.format("/pkg/ly.game_editor/assets/icon/icon_%s.texture", name), { compile = true })
		end
		selected_pkg = user_data.get("editor.selected.pkg")
		view_path = user_data.get("editor.view.path")
		selected_file = user_data.get("editor.selected.file")
	end

	local function set_selected_file(value)
		if selected_file ~= value then 
			selected_file = value
			user_data.set("editor.selected.file", selected_file or "", true)
		end
	end

	local function set_view_path(path)
		if path == "" then 
			path = nil 
		end
		view_path = path
		user_data.set("editor.view.path", view_path or "", true)
		set_selected_file()
	end

	local function set_selected_pkg(value)
		if value == selected_pkg then return end 
		selected_pkg = value
		user_data.set("editor.selected.pkg", selected_pkg or "")
		set_view_path()
	end

	local function current_full_path(_view_path)
		local tree = editor.files.resource_tree[selected_pkg]
		if tree then
			local full_path = tree.full_path
			local view = _view_path or view_path
			if view then 
				full_path = full_path .. "/" .. view
			end
			return full_path
		end
	end

	local function draw_pkgs(size_x)
		ImGui.SetCursorPos(5, 3)
		ImGui.BeginGroup()
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
		for i, name in ipairs(editor.tbParams.pkgs) do 
			if not selected_pkg then set_selected_pkg(name) end
			if editor.style.draw_btn(name, selected_pkg == name, {size_x = size_x - 10} ) then 
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
			if editor.style.draw_btn(label) then 
				set_view_path(table.concat(arr, "/", 2, i))
			end

			if imgui_utils.GetDragDropPayload("DragWndFile") and ImGui.BeginDragDropTarget() then 
				local payload = imgui_utils.AcceptDragDropPayload("DragWndFile")
				if payload then
					local full_path = current_full_path(view_path)
					drop_from = string.format("%s/%s", full_path, payload)
					local str = table.concat(arr, "/", 2, i)
					local full_path = current_full_path(str)
					drop_to = string.format("%s/%s", full_path, payload)
					drop_to = string.gsub(drop_to, "//", "/")
					print("drop end", drop_from, drop_to)
					need_open_drop_menu = drop_from ~= drop_to 
				end
				ImGui.EndDragDropTarget()
			end

			ImGui.SameLine()
			if i < #arr then 
				ImGui.Text(">")
				ImGui.SameLine()
			end
		end
	end

	local function action_delete_file(ext, name, display, isDir)
		---@type ly.game_editor.dialogue_msgbox.open_param
		local open_param = {}
		open_param.title = "删除文件"
		open_param.msg = string.format("是否确认删除文件: %s ?\n该操作不可撤销。", name)
		open_param.onOK = function()
			local path = string.format("%s/%s", current_full_path(), name)
			if isDir then
				lfs.remove_all(path)
			else 
				lfs.remove(path)
			end
			editor.files.refresh_tree(selected_pkg, view_path)
		end
		editor.dialogue_msgbox.open(open_param)
	end

	local function action_clone_file(ext, name, display, isDir)
		local full_path = current_full_path()
		---@type ly.game_editor.dialogue_input.open_param
		local param = {}
		param.title = "克隆文件"
		param.header = "名字"
		param.isFileName = true 
		param.value = display .. "_new"
		param.onCheck = function(name)
			local root = editor.files.resource_tree[selected_pkg]
			local tree = editor.files.find_tree_by_path(root, view_path)
			if tree then 
				if isDir then 
					for i, v in ipairs(tree.dirs) do 
						if v.name == name then 
							return false, "文件已经存在"
						end
					end
				else
					local file_name = string.format("%s.%s", name, ext)
					for i, v in ipairs(tree.files) do 
						if v.name == file_name then 
							return false, "文件已经存在"
						end
					end
				end
				return true
			end
			return false, "未知错误"
		end
		param.onOK = function(_name)
			if isDir then 
				local from = string.format("%s/%s", full_path, name)
				local to = string.format("%s/%s", full_path, _name)
				lfs.copy(from, to)
			else
				_name = _name .. "." .. ext
				local from = string.format("%s/%s", full_path, name)
				local to = string.format("%s/%s", full_path, _name)
				lfs.copy_file(from, to)
			end
			editor.files.refresh_tree(selected_pkg, view_path)
			set_selected_file(_name)
		end
		editor.dialogue_input.open(param)
	end

	local function action_new_file(ext)
		local full_path = current_full_path()
		---@type ly.game_editor.dialogue_input.open_param
		local param = {}
		param.title = "新建文件"
		param.header = "文件名"
		param.isFileName = true 
		param.value = "filename"
		param.onCheck = function(name)
			local root = editor.files.resource_tree[selected_pkg]
			local tree = editor.files.find_tree_by_path(root, view_path)
			if tree then 
				for i, v in ipairs(tree.files) do 
					if v.ext == ext and v.short_name == name then 
						return false, "文件已经存在"
					end
				end
				return true
			end
			return false, "未知错误"
		end
		param.onOK = function(name)
			local file_name = string.format("%s.%s", name, ext)
			local path = string.format("%s/%s", full_path, file_name)
			local f<close> = assert(io.open(path, "w"))
			f:write("")
			print("create file", path)
			editor.files.refresh_tree(selected_pkg, view_path)
			set_selected_file(file_name)
		end
		editor.dialogue_input.open(param)
	end

	local function action_new_folder()
		local full_path = current_full_path()
		---@type ly.game_editor.dialogue_input.open_param
		local param = {}
		param.title = "新建文件夹"
		param.header = "名字"
		param.isFileName = true 
		param.value = "name"
		param.onCheck = function(name)
			local root = editor.files.resource_tree[selected_pkg]
			local tree = editor.files.find_tree_by_path(root, view_path)
			if tree then 
				for i, v in ipairs(tree.dirs) do 
					if v.name == name then 
						return false, "文件夹已经存在"
					end
				end
				return true
			end
			return false, "未知错误"
		end
		param.onOK = function(name)
			local path = string.format("%s/%s", full_path, name)
			lfs.create_directory(path)
			print("create dir", path)
			editor.files.refresh_tree(selected_pkg, view_path)
			set_selected_file(name)
		end
		editor.dialogue_input.open(param)
	end

	local function action_rename_file(ext, name, display, isDir)
		local full_path = current_full_path()
		---@type ly.game_editor.dialogue_input.open_param
		local param = {}
		param.title = "文件改名"
		param.header = "名字"
		param.isFileName = true 
		param.value = display
		param.onCheck = function(name)
			local root = editor.files.resource_tree[selected_pkg]
			local tree = editor.files.find_tree_by_path(root, view_path)
			if tree then 
				if isDir then 
					for i, v in ipairs(tree.dirs) do 
						if v.name == name then 
							return false, "文件已经存在"
						end
					end
				else
					local file_name = string.format("%s.%s", name, ext)
					for i, v in ipairs(tree.files) do 
						if v.name == file_name then 
							return false, "文件已经存在"
						end
					end
				end
				return true
			end
			return false, "未知错误"
		end
		param.onOK = function(_name)
			if isDir then 
				local from = string.format("%s/%s", full_path, name)
				local to = string.format("%s/%s", full_path, _name)
				lfs.rename(from, to)
			else
				_name = _name .. "." .. ext
				local from = string.format("%s/%s", full_path, name)
				local to = string.format("%s/%s", full_path, _name)
				lfs.rename(from, to)
			end
			editor.files.refresh_tree(selected_pkg, view_path)
			set_selected_file(_name)
		end
		editor.dialogue_input.open(param)
	end

	local function draw_file_menu(ext, name, display, isDir, path, file)
		if ImGui.BeginPopupContextItem() then
			set_selected_file(name)
			if not isDir and ImGui.MenuItem("打 开") then
				editor.open_tab(selected_pkg .. "/" .. path)
			end
			if ImGui.MenuItem("收 藏") then
				editor.portal.add(selected_pkg .. "/" .. path)
			end
			ImGui.Separator()
			if ImGui.MenuItem("改 名") then
				action_rename_file(ext, name, display, isDir)
			end
			if ImGui.MenuItem("删 除") then
				action_delete_file(ext, name, display, isDir)
			end
			if ImGui.MenuItem("克 隆") then
				action_clone_file(ext, name, display, isDir)
			end
			if ImGui.MenuItem("复制文件路径") then
				local path = view_path and string.format("/pkg/%s/%s/%s", selected_pkg, view_path, name) 
					or string.format("/pkg/%s/%s", selected_pkg, name)
				ImGui.SetClipboardText(path)
			end
			if ImGui.MenuItem("在文件浏览器中查看") then
				local path = file.full_path:gsub("/","\\")
				os.execute("c:\\windows\\explorer.exe /select,".. path)
			end
			ImGui.EndPopup()
		end
	end

	local function draw_content_menu()
		if ImGui.IsWindowHovered() and not ImGui.IsAnyItemHovered() and not imgui_utils.GetDragDropPayload("DragWndFile")  then 
			if ImGui.IsMouseReleased(ImGui.MouseButton.Right) then
				ImGui.OpenPopup("my_context_menu");
				set_selected_file()
			elseif ImGui.IsMouseReleased(ImGui.MouseButton.Left) then 
				set_selected_file()
			end
		end

		if ImGui.IsMouseReleased(ImGui.MouseButton.Right) or ImGui.IsMouseReleased(ImGui.MouseButton.Left) then 
			is_window_active = ImGui.IsWindowHovered()
		end 

		if selected_pkg and ImGui.BeginPopup("my_context_menu") then
			if ImGui.MenuItem("刷 新") then 
				editor.files.refresh_tree(selected_pkg, view_path)
			end
			if ImGui.MenuItem("新建文件夹") then 
				action_new_folder()
			end
			if ImGui.BeginMenu("新建文件") then 
				for i, v in ipairs(tb_new_file_desc) do 
					if ImGui.MenuItem("新建 " .. v[2]) then
						action_new_file(v[1])
					end
				end
				ImGui.EndMenu()
			end 
            ImGui.EndPopup()
        end
	end

	function api.draw(deltatime, line_y)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local dpi = dep.common.imgui_utils.get_dpi_scale()
		local left_x = 150 * dpi
		ImGui.SetCursorPos(0, 0)
		ImGui.BeginChild("wnd_files_pkgs", left_x, size_y, ImGui.ChildFlags({"Border"}))
		draw_pkgs(left_x)
		ImGui.EndChild()
		
		local root = editor.files.resource_tree[selected_pkg]
		if not root then return end 
	
		ImGui.SetCursorPos(left_x + 1, 3)
		draw_view_path()

		local tree = editor.files.find_tree_by_path(root, view_path)
		if not tree then return end

		ImGui.SetCursorPos(left_x, line_y)
		ImGui.BeginChild("wnd_files_content", size_x - left_x, size_y - line_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 15, 10)
        ImGui.PushStyleVarImVec2(ImGui.StyleVar.ItemSpacing, 10, 5)
		
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local start_x = 5
		local pos = {x = start_x, y = 8}
		local texSize = {x = 35 * dpi, y = 35 * dpi}
		local btnSize = {x = 70 * dpi, y = line_y}
		local maskSize = {x = btnSize.x - 5, y = texSize.y + 5}
		local cell<const> = {x = btnSize.x + 10, y = maskSize.y + btnSize.y + 5}
		local index = 0
		local function draw_file(ext, name, display, isDir, path, file)
			index = index + 1
			local temp = {x = pos.x + cell.x * 0.5, y = pos.y}
			ImGui.SetCursorPos(temp.x - texSize.x * 0.5, temp.y)
			ImGui.Image(dep.textureman.texture_get(icons[ext].id), texSize.x, texSize.y)
			
			do
				ImGui.SetCursorPos(temp.x - maskSize.x * 0.5, temp.y)
				local label = "##btn_file_node_mask_" .. index
				local style<close> = editor.style.use(GStyle.file_normal)
				if ImGui.ButtonEx(label, maskSize.x, maskSize.y) then 
					set_selected_file(name)
				end
				if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
					if isDir then 
						set_view_path(view_path and (view_path .. "/" .. name) or name)
					else
						editor.open_tab(selected_pkg .. "/" .. path)
					end
				end
				if ImGui.BeginDragDropSource() then 
					set_selected_file(name)
					imgui_utils.SetDragDropPayload("DragWndFile", name);
					ImGui.Text("正在拖动 " .. name);
					ImGui.EndDragDropSource();
				end
	
				if isDir and imgui_utils.GetDragDropPayload("DragWndFile") and ImGui.BeginDragDropTarget() then 
					local payload = imgui_utils.AcceptDragDropPayload("DragWndFile")
					if payload then
						need_open_drop_menu = true
						local full_path = current_full_path()
						drop_from = string.format("%s/%s", full_path, payload)
						drop_to = string.format("%s/%s/%s", full_path, name, payload)
						set_selected_file(name)
					end
					ImGui.EndDragDropTarget()
				end
			end
			draw_file_menu(ext, name, display, isDir, path, file)
			do
				ImGui.SetCursorPos(pos.x + 5, pos.y + texSize.y )
				local is_selected = name == selected_file
				local type
				if is_window_active and is_selected then 
					type = GStyle.file_active
				else 
					type = is_selected and GStyle.file_sel or GStyle.file_normal
				end
				local style<close> = editor.style.use(type)
				local label = string.format("%s##btn_file_node_%s", display, index)
				if ImGui.ButtonEx(label, btnSize.x, btnSize.y) then 
					set_selected_file(name)
				end
			end

			if pos.x + cell.x * 2 >= size_x + 10 then 
				pos.y = pos.y + cell.y 
				pos.x = start_x
			else 
				pos.x = pos.x + cell.x
			end
		end
		
		draw_content_menu()
		for i, v in ipairs(tree.dirs) do 
			draw_file('folder', v.name, v.name, true, v.r_path, v)
		end

		for i, v in ipairs(tree.files) do 
			draw_file(v.ext, v.name, v.short_name, false, v.r_path, v)
		end

		if need_open_drop_menu then 
			need_open_drop_menu = false
			ImGui.OpenPopup(drop_menu_name, ImGui.PopupFlags { "None" });
		end
		if ImGui.BeginPopupContextItemEx(drop_menu_name) then 
			if ImGui.MenuItem("移动到此处") then 
				lfs.copy(drop_from, drop_to, lfs.copy_options.overwrite_existing)
				print("move from to:", drop_from, drop_to)
				editor.msg_hints.show("文件移动成功", "ok")
				lfs.remove_all(drop_from)
				editor.files.refresh_tree(selected_pkg, "")
			end
			if ImGui.MenuItem("克隆到此处") then 
				lfs.copy(drop_from, drop_to, lfs.copy_options.overwrite_existing)
				print("copy from to:", drop_from, drop_to)
				editor.msg_hints.show("文件克隆成功", "ok")
				editor.files.refresh_tree(selected_pkg, "")
			end
			ImGui.EndPopup()
		end
		ImGui.PopStyleVarEx(2)
		ImGui.EndChild()
		api.handleKeyEvent()
	end

	function api.get_icon_id_by_ext(ext)
		local icon = icons[ext]
		return icon and icon.id 
	end

	function api.browse(path)
		local arr = lib.split(path, "/")
		set_selected_pkg(arr[1])
		local r_path = table.concat(arr, "/", 2)
		local ext = lib.get_file_ext(r_path)
		if ext then 
			set_view_path(lib.get_file_root(r_path))
			set_selected_file(lib.get_file_name(r_path))
		else
			set_view_path(r_path)
		end
	end

	function api.select_in_folder(vfs_path)
		local full_path = editor.files.vfs_path_to_full_path(vfs_path)
		local path = full_path:gsub("/","\\")
		os.execute("c:\\windows\\explorer.exe /select,".. path)
	end

	function api.handleKeyEvent()
		if not is_window_active or ImGui.IsPopupOpen("", ImGui.PopupFlags{'AnyPopup'}) then 
			return 
		end
		local function current_tree()
			local root = editor.files.resource_tree[selected_pkg]
			if not root then return end 
			return editor.files.find_tree_by_path(root, view_path)
		end
		if ImGui.IsKeyPressed(ImGui.Key.Delete, false) and selected_file then 
			local tree = current_tree()
			if not tree then return end
			
			for i, v in ipairs(tree.dirs) do 
				if v.name == selected_file then 
					action_delete_file(nil, v.name, v.name, true)
					break
				end
			end
			for i, v in ipairs(tree.files) do 
				if v.name == selected_file then 
					action_delete_file(v.ext, v.name, v.short_name, false)
					break
				end
			end
		end
		
		if ImGui.IsKeyPressed(ImGui.Key.F2, false) and selected_file then 
			local tree = current_tree()
			if not tree then return end
			for i, v in ipairs(tree.dirs) do 
				if v.name == selected_file then 
					action_rename_file(nil, v.name, v.name, true)
					break
				end
			end
			for i, v in ipairs(tree.files) do 
				if v.name == selected_file then 
					action_rename_file(v.ext, v.name, v.short_name, false)
					break
				end
			end
		end
	end

	init()
	return api
end

return {new = new}