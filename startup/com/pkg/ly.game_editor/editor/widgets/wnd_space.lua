--------------------------------------------------------
-- 工作空间绘制
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ed = dep.ed 
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils
local lib = dep.common.lib

---@param editor ly.game_editor.editor
local function new(editor)
	local api = {}			---@class ly.game_editor.wnd_space
	local space 			---@type ly.game_editor.space
	local mouse_x, mouse_y 

	function api.draw(deltatime, line_y)
		space = editor.workspaces.current_space()
		if not space then return end 
		
		if ImGui.IsMouseClicked(ImGui.MouseButton.Left) or ImGui.IsMouseClicked(ImGui.MouseButton.Right) then
			mouse_x, mouse_y = ImGui.GetMousePos()
		else 
			mouse_x, mouse_y = nil, nil
		end

		---@param view ly.game_editor.viewport  要渲染的窗口自身
		local function draw (view)
			if view.type == 0 then 		-- 全屏
				return api.draw_viewport(deltatime, view, line_y)
			end 
			
			local one = view.children[1]
			local two = view.children[2]
			if view.type == 1 then	-- 水平分割
				one.pos_x = view.pos_x	
				one.pos_y = view.pos_y
				one.size_x = view.size_x
				one.size_y = view.size_y * one.size_rate

				two.pos_x = view.pos_x
				two.pos_y = one.pos_y + one.size_y
				two.size_x = view.size_x
				two.size_y = view.size_y * two.size_rate
			elseif view.type == 2 then	-- 竖直分割
				one.pos_x = view.pos_x	
				one.pos_y = view.pos_y
				one.size_x = view.size_x * one.size_rate
				one.size_y = view.size_y

				two.pos_x = one.pos_x + one.size_x
				two.pos_y = one.pos_y
				two.size_x = view.size_x * two.size_rate
				two.size_y = view.size_y
			end
			api.draw_splitter(view, one, two)
			draw(one)
			draw(two)
		end

		local size_x, size_y = ImGui.GetContentRegionAvail()
		local root = space.view
		root.pos_x = 0
		root.pos_y = 0
		root.size_x = size_x
		root.size_y = size_y
		draw(root)		
	end

	---@param view ly.game_editor.viewport  要渲染的窗口自身
	---@param second ly.game_editor.viewport  第二个子节点
	function api.draw_splitter(view, one, two) 
		ImGui.SetCursorPos(view.pos_x, view.pos_y)
		ImGui.BeginChild("viewport_" .. view.id , view.size_x, view.size_y, ImGui.ChildFlags({}))
		if view.type == 1 then 
			local size1 = two.pos_y - view.pos_y - 2
			local size2 = two.size_y
			local newSize1, newSize2 = ed.Splitter(false, 4, size1, size2, 15, 15)
			if newSize1 and newSize1 ~= size1 then 
				one.size_rate = (newSize1 + 2) / view.size_y
				two.size_rate = 1 - one.size_rate
			end
		else
			local size1 = two.pos_x - view.pos_x - 2
			local size2 = two.size_x
			local newSize1, newSize2 = ed.Splitter(true, 4, size1, size2, 15, 15)
			if newSize1 and newSize1 ~= size1 then 
				one.size_rate = (newSize1 + 2) / view.size_x
				two.size_rate = 1 - one.size_rate
			end
		end
		ImGui.EndChild()
	end

	---@param view ly.game_editor.viewport  要渲染的窗口自身
	function api.draw_viewport(deltatime, view, line_y)
		ImGui.SetCursorPos(view.pos_x, view.pos_y)
		local pos_x, pos_y = ImGui.GetCursorScreenPos()
		ImGui.BeginChild("viewport_" .. view.id , view.size_x, view.size_y, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(3, 3)
			ImGui.BeginGroup()
				ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
				api.draw_tabs(view, line_y)
				ImGui.PopStyleVar()
			ImGui.EndGroup()

			local body_y = view.size_y - line_y
			if body_y > 3 then
				ImGui.SetCursorPos(0, line_y)
				ImGui.PushStyleColorImVec4(ImGui.Col.ChildBg, 0.1, 0.1, 0.1, 0.8)
				ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.9, 0.9, 0.9, 1)
				ImGui.BeginChild("viewport_content_" .. view.id, view.size_x, body_y, ImGui.ChildFlags({"Border"}))
				editor.wnd_mgr.render(deltatime, view, space.get_active_viewport() == view)
				ImGui.EndChild()
				ImGui.PopStyleColorEx(2)

				local payload = imgui_utils.GetDragDropPayload("DragViewTab")
				if payload then 
					ImGui.SetCursorPos(0, line_y)
					ImGui.BeginChild("viewport_content_drop_" .. view.id, view.size_x, body_y, ImGui.ChildFlags({}))
					local start_x, start_y = ImGui.GetWindowPos()
					local x, y = ImGui.GetMousePos()
					local rate_x = (x - start_x) / view.size_x
					local rate_y = (y - start_y) / view.size_y
					if rate_x >= 0 and rate_y >= 0 and rate_x <= 1 and rate_y <= 1 then 
						api.draw_dropview_hint(view, payload, rate_x, rate_y, start_x, start_y)
					end
					ImGui.EndChild()
				end
			end
		ImGui.EndChild()
		-- 判断鼠标当前点击在哪个viewport上
		if mouse_x and mouse_x >= pos_x and mouse_x <= (pos_x + view.size_x) and mouse_y >= pos_y and mouse_y <= (pos_y + view.size_y) then 
			space.set_active_viewport(view.id)
		end
	end

	--- 绘制窗口tab列表
	---@param view ly.game_editor.viewport  窗口
	function api.draw_tabs(view, line_y)
		do 
			local payload = imgui_utils.GetDragDropPayload("DragViewTab")
			local arr = lib.split(payload, ";")
			local fromViewId = tonumber(arr[1])
			if fromViewId and fromViewId ~= view.id then
				local pos_x, pos_y = ImGui.GetCursorPos()
				ImGui.SetNextItemAllowOverlap();
				ImGui.InvisibleButton("##btn_drop_to_tab_" .. view.id, view.size_x - 5, line_y - 5) 
				if ImGui.BeginDragDropTarget() then 
					local payload = imgui_utils.AcceptDragDropPayload("DragViewTab")
					if payload then
						local arr = lib.split(payload, ";")
						local fromViewId = tonumber(arr[1])
						local fromPath = arr[2]
						view.tabs.open_tab(fromPath)
						space.set_active_viewport(view.id)
						local view = space.find_viewport_by_id(fromViewId)
						if view then 
							view.tabs.close_tab(fromPath)
						end
					end
					ImGui.EndDragDropTarget()
				end
				ImGui.SetCursorPos(pos_x, pos_y)
			end
		end

		local cur = view.tabs.get_active_path()
		local is_current_view = view == space.get_active_viewport()
		for i, v in ipairs(view.tabs.list) do 
			local wnd = editor.wnd_mgr.find_window(v.path)
			local name = v.name
			if wnd and wnd.is_dirty() then 
				name = "*" .. name
			end
			local label = string.format("%s##btn_view_%d_%s", name, view.id, v.name)
			local style_name
			if is_current_view then 
				style_name = cur == v.path and GStyle.tab_active or GStyle.btn_normal
			else 
				style_name = cur == v.path and GStyle.btn_normal_selected or GStyle.btn_normal
			end
			if editor.style.draw_style_btn(label, style_name) then
				view.tabs.set_active_path(v.path)
			end
			if ImGui.BeginPopupContextItem() then 
				view.tabs.set_active_path(v.path)
				if ImGui.MenuItem("保 存") then 
					if wnd then wnd.save() end
				end
				if ImGui.MenuItem("关 闭") then 
					view.tabs.close_tab(v)
				end
				if ImGui.MenuItem("关闭其他所有") then 
					view.tabs.close_other_tabs(v, editor)
				end
				if wnd and wnd.has_preview_mode and wnd.has_preview_mode() then 
					if v.show_mode == 2 then 
						if ImGui.MenuItem("切换至设计模式") then 
							v.show_mode = 1
						end
					else 
						if ImGui.MenuItem("切换至预览模式") then 
							v.show_mode = 2
						end
					end
				end
				ImGui.Separator()
				if ImGui.MenuItem("选 中") then 
					editor.wnd_files.browse(v.path)
				end
				if ImGui.MenuItem("重新加载") then 
					if wnd then wnd.reload() end
				end
				if ImGui.MenuItem("克隆到对面标签") then 
					space.clone_tab(view, v.path)
				end
				if ImGui.MenuItem("在文件浏览器中显示") then 
					editor.wnd_files.select_in_folder(v.path)
				end
				ImGui.EndPopup()
			end

			if ImGui.BeginDragDropSource() then 
				view.tabs.set_active_path(v.path)
				imgui_utils.SetDragDropPayload("DragViewTab", string.format("%d;%s;%d", view.id, v.path, i));
				ImGui.Text("正在拖动 " .. v.name);
				ImGui.EndDragDropSource();
			end

			if imgui_utils.GetDragDropPayload("DragViewTab") and ImGui.BeginDragDropTarget() then 
				local payload = imgui_utils.AcceptDragDropPayload("DragViewTab")
            	if payload then
					local arr = lib.split(payload, ";")
					local fromViewId = tonumber(arr[1])
					local fromPath = arr[2]
					local index = tonumber(arr[3])

					if fromViewId == view.id then 
						local tb = table.remove(view.tabs.list, index)
						table.insert(view.tabs.list, i, tb)
					else
						view.tabs.open_tab(fromPath, i)
						local view = space.find_viewport_by_id(fromViewId)
						if view then 
							view.tabs.close_tab(fromPath)
						end
					end
				end
				ImGui.EndDragDropTarget()
			end
			ImGui.SameLine()
		end

		if #view.tabs.list == 0 then 
			local label = string.format(" 移 除 ##btn_remove_view_%d", view.id)
			if editor.style.draw_btn(label) then
				space.remove_viewport(view.id)
			end
			ImGui.SameLine()
		end

		local menu = "viewport_add_tab_" .. view.id
		if editor.style.draw_btn(" + ##btn_add_tab_" .. view.id) then
			ImGui.OpenPopup(menu, ImGui.PopupFlags { "None" });
		end
		if ImGui.BeginPopupContextItemEx(menu) then 
			if ImGui.MenuItem("+ 收藏") then 
			end
			if ImGui.MenuItem("+ 文件夹") then 
			end
			if ImGui.MenuItem("+ GM界面") then 
			end
			if ImGui.MenuItem("+ 自定义界面") then 
			end
			ImGui.EndPopup();
		end
	end

	---@param view ly.game_editor.viewport  窗口
	---@param drop_content string 拖动内容
	function api.draw_dropview_hint(view, drop_content, rate_x, rate_y, start_x, start_y)
		local size_x, size_y	
		local type 
		if rate_x > 0.3 and rate_x < 0.7 then 
			type = rate_y < 0.5 and "up" or "down"
		else
			if rate_y < 0.3 then 
				type = "up"
			elseif rate_y < 0.7 then  	-- 继续判断左右
				type = rate_x < 0.5 and "left" or "right"
			else 
				type = "down"
			end
		end
		if type == "up" then
			size_x = view.size_x
			size_y = view.size_y * 0.5
		elseif type == "down" then 
			start_y = start_y + view.size_y * 0.5 - 30
			size_x = view.size_x
			size_y = view.size_y * 0.5
		elseif type == "left" then 
			size_x = view.size_x * 0.5
			size_y = view.size_y - 30
		elseif type == "right" then 
			start_x = start_x + view.size_x * 0.5
			size_x = view.size_x * 0.5
			size_y = view.size_y - 30
		end

		ImGui.SetCursorScreenPos(start_x, start_y)
		ImGui.ButtonEx("##btn_dropview_hint", size_x, size_y)
		if ImGui.BeginDragDropTarget() then 
			local payload = imgui_utils.AcceptDragDropPayload("DragViewTab")
			if payload then
				local arr = lib.split(payload, ";")
				local fromViewId = tonumber(arr[1])
				local fromPath = arr[2]
				local src_view = space.find_viewport_by_id(fromViewId)
				if src_view then 
					src_view.tabs.close_tab(fromPath)
				end

				---@type ly.game_editor.viewport
				local dest_view
				if type == "left" or type == "right" then 
					dest_view = space.split(view.id, 2)
				else
					dest_view = space.split(view.id, 1)
				end
				if type == "left" or type == "up" then 
					dest_view = dest_view.children[1]
				else 
					dest_view = dest_view.children[2]
				end
				dest_view.tabs.open_tab(fromPath)
				space.set_active_viewport(dest_view.id)

				local src_view = space.find_viewport_by_id(fromViewId)
				if src_view and #src_view.tabs.list == 0 and src_view.type == 0 then 
					space.remove_viewport(src_view.id)
				end
			end
			ImGui.EndDragDropTarget()
		end
	end

	return api
end

return {new = new}