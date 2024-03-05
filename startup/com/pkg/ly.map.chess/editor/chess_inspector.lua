local dep = require 'dep' ---@type ly.map.chess.dep
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor chess_editor
---@return chess_region_inspector
local create = function(editor)
	---@class chess_region_inspector
	local api = {}
	local data_hander = editor.data_hander
	local stack = editor.stack
	local region; ---@type chess_map_region_tpl

	function api.on_render()
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local h1 = size_y * 0.7
		region = data_hander.cur_region()
		if not region then return end 

		ImGui.BeginChild("##chess_right_1", size_x, h1, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()
			if data_hander.is_multi_selected(region) then 
				-- 处理多选视图
			else
				local type, gridId, layerId = data_hander.get_first_selected(region)
				if type == "object" then 
					local gridData = data_hander.get_grid_data(region, layerId, gridId)
					if gridData then 
						api.draw_checkbox_invisible(gridData)
					end
				end 
			end
		ImGui.EndGroup()
		ImGui.EndChild()

		ImGui.SetCursorPos(0, h1)
		ImGui.BeginChild("##chess_right_2", size_x, size_y - h1, ImGui.ChildFlags({"Border"}))
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()
			if imgui_utils.draw_btn("显示区域", data_hander.data.show_ground, {size_x = size_x - 13}) then 
				data_hander.data.show_ground = not data_hander.data.show_ground
				stack.snapshoot(false)
			end
			local n = data_hander.get_invisible_count(region)
			if imgui_utils.draw_btn("清空不可见:" .. n, false, {size_x = size_x - 13}) then 
				if n > 0 then 
					data_hander.clear_invisible(region)
				end
			end
		ImGui.EndGroup()
		ImGui.EndChild()
	end

	---@param gridData chess_grid_tpl
	function api.draw_checkbox_invisible(gridData)
		local checkbox_value = {data_hander.is_invisible(region, gridData.id)}
		local change, v = ImGui.Checkbox("不可见##checkbox_visible_obj", checkbox_value)
        if change then 
			if checkbox_value[1] then 
				data_hander.add_invisible(region, gridData.id)
			else 
				data_hander.remove_invisible(region, gridData.id)
			end
			stack.snapshoot(false)
		end
	end


	return api 
end


return {create = create}