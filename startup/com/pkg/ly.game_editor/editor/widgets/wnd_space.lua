--------------------------------------------------------
-- 工作空间绘制
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ed = dep.ed 
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

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
				return api.draw_viewport(view, line_y)
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
	function api.draw_viewport(view, line_y)
		ImGui.SetCursorPos(view.pos_x, view.pos_y)
		local pos_x, pos_y = ImGui.GetCursorScreenPos()
		ImGui.BeginChild("viewport_" .. view.id , view.size_x, view.size_y, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(3, 3)
		ImGui.BeginGroup()
		local cur = view.tabs.get_active_path()
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		for i, v in ipairs(view.tabs.list) do 
			local label = string.format("%s##btn_view_%d_%s", v.name, view.id, v.name)
			if imgui_utils.draw_btn(label, cur == v.path) then
				view.tabs.set_active_path(v.path)
			end
			if ImGui.BeginPopupContextItem() then 
				view.tabs.set_active_path(v.path)
				if ImGui.MenuItem("关闭") then 
					view.tabs.close_tab(v)
				end
				if ImGui.MenuItem("关闭其他") then 
					view.tabs.close_others(v)
				end
				ImGui.EndPopup()
			end
			ImGui.SameLine()
		end
		local menu = "viewport_add_tab_" .. view.id
		if imgui_utils.draw_btn(" + ##btn_add_tab_" .. view.id) then
			ImGui.OpenPopup(menu, ImGui.PopupFlags { "None" });
		end
		if ImGui.BeginPopupContextItemEx(menu) then 
			if ImGui.MenuItem("+ GM界面") then 

			end
			if ImGui.MenuItem("+ 自定义界面") then 

			end
			ImGui.EndPopup();
		end
		ImGui.PopStyleVar()
		ImGui.EndGroup()

		local body_y = view.size_y - line_y
		if body_y > 3 then
			ImGui.SetCursorPos(0, line_y)
			ImGui.BeginChild("viewport_content_" .. view.id, view.size_x, body_y, ImGui.ChildFlags({"Border"}))
			ImGui.Text("content")
			ImGui.EndChild()
		end

		ImGui.EndChild()

		if mouse_x and mouse_x >= pos_x and mouse_x <= (pos_x + view.size_x) and mouse_y >= pos_y and mouse_y <= (pos_y + view.size_y) then 
			space.set_active_viewport(view.id)
		end
	end

	return api
end

return {new = new}