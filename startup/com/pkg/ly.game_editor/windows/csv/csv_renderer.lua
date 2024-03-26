--------------------------------------------------------
-- csv 窗口渲染
--------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.csv.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.csv.renderer
	local api = {}
	api.data_hander = data_hander
	api.stack = stack

	function api.set_data(data)
		data_hander.set_data(data)
		stack.set_data_handler(data_hander)
		stack.snapshoot()
	end

	function api.draw_left()
		ImGui.BeginGroup()
		ImGui.Dummy(5, 2)
		ImGui.Text(" 开 关 ")
		local checkbox_value = {}
		local heads = data_hander.get_heads()
		for i, v in ipairs(heads) do 
			checkbox_value[1] = v.visible
			local label = string.format("%s##checkbox_%s_i", v.key, v.key, i)
			local change, value = ImGui.Checkbox(label, checkbox_value)
			if change then 
				v.visible = checkbox_value[1]
			end
		end
		ImGui.EndGroup()
	end

	function api.update(delta_time)
		local all_x = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(5, 0)
		api.draw_left()
		ImGui.SameLine()
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local detail_x = 300
		if size_x <= 20 then return end 

		local content_x = size_x - detail_x;
		if content_x <= 50 then content_x = size_x end

		ImGui.BeginChild("content", content_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.Text("hello world")
		ImGui.PopStyleVar()
		ImGui.EndChild()

		if content_x + detail_x == size_x then 
			ImGui.SetCursorPos(all_x - detail_x, 0)
			ImGui.BeginChild("detail", detail_x, size_y, ImGui.ChildFlags({"Border"}))
			ImGui.Text("detail")
			ImGui.EndChild()
		end
	end

	return api
end

return {new = new}