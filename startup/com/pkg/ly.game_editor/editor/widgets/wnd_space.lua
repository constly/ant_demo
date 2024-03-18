--------------------------------------------------------
-- 工作空间绘制
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ed = dep.ed 
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
local function new(editor)
	local api = {}			---@class ly.game_editor.wnd_files
	local space 			---@type ly.game_editor.space

	function api.draw(deltatime)
		space = editor.workspaces.current_space()
		if not space then return end 
		
		---@param view ly.game_editor.viewport  要渲染的窗口自身
		local function draw (view)
			if view.type == 0 then 		-- 全屏
				return api.draw_viewport(view)
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
			draw(one)
			draw(two)
		end

		local newSize1, newSize2 = ed.Splitter(false, 4, 200, 100, 10, 10)

		local size_x, size_y = ImGui.GetContentRegionAvail()
		local root = space.view
		root.pos_x = 0
		root.pos_y = 0
		root.size_x = size_x
		root.size_y = size_y
		draw(root)

		
	end

	---@param view ly.game_editor.viewport  要渲染的窗口自身
	function api.draw_viewport(view)
		ImGui.SetCursorPos(view.pos_x, view.pos_y)

		ImGui.BeginChild("panel_window_middle_" .. view.id , view.size_x, view.size_y, ImGui.ChildFlags({"Border"}))
		ImGui.BeginGroup()
		ImGui.Button("config")
		ImGui.SameLine()
		ImGui.Button("map_01")
		ImGui.EndGroup()
		ImGui.EndChild()
	end

	return api
end

return {new = new}