---------------------------------------------------------------------------
-- 编辑器绘制
---------------------------------------------------------------------------
local dep = require 'dep' ---@type ly.map.chess.dep 
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor chess_editor
local create = function(editor)
	---@class chess_editor_draw
	local chess = {}
	
	function chess.on_render(_deltatime)
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 0, 0)
		local start_x = 3
		local fix_x, fix_y = 6, 7;
		ImGui.SetCursorPos(start_x, 0)
		local size_x, size_y = ImGui.GetContentRegionMax()
		local size_left = 150;
		local size_right = 150;
		local offset_x = 0
		size_y = size_y + fix_y
		ImGui.BeginChild("##chess_left", size_left, size_y, ImGui.ChildFlags({"Border"}))
			chess.draw_left()
		ImGui.EndChild()

		ImGui.SetCursorPos(size_left + offset_x + start_x, 0)
		local size = size_x - size_left - size_right - 2 * offset_x
		ImGui.BeginChild("##chess_middle", size, size_y, ImGui.ChildFlags({"Border"}))
			chess.draw_middle()
		ImGui.EndChild()

		ImGui.SetCursorPos(size_left + size + offset_x * 2 + start_x, 0)
		ImGui.BeginChild("##chess_right", size_right + fix_x, size_y, ImGui.ChildFlags({"Border"}))
			chess.draw_right()
		ImGui.EndChild()
		ImGui.PopStyleVar()
	end

	function chess.draw_left()
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.Dummy(2, 3);
		imgui_utils.draw_text_center("物件列表")

		local h1 = size_y * 0.7
		ImGui.BeginChild("##chess_left_1", size_x, h1, ImGui.ChildFlags({"Border"}))
			
		ImGui.EndChild()

		ImGui.Dummy(5, 3);
		imgui_utils.draw_text_center("区 域")
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("##chess_left_2", size_x, size_y, ImGui.ChildFlags({"Border"}))
			
		ImGui.EndChild()
	end

	function chess.draw_middle()
		ImGui.Text("middle")
		ImGui.SetCursorPos(100, 100)
		local nums = {-3, -2, -1, -0.01, 0, 0.01, 1, 1, 3}
		for i, v in ipairs(nums) do 
			ImGui.Button(v)
			ImGui.SameLine()
		end
	end

	function chess.draw_right()
		ImGui.Text("right")
	end

	return chess
end 

return {create = create}