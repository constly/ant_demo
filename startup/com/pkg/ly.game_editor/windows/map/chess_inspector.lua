local dep = require 'dep' ---@type ly.map.chess.dep
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor ly.game_editor.editor
---@param renderer ly.map.renderer
---@return chess_region_inspector
local function new(editor, renderer)
	---@class chess_region_inspector
	local api = {}
	local data_hander = renderer.data_hander
	local stack = renderer.stack
	local region; ---@type chess_map_region_tpl
	local header_x
	local size_x, size_y

	function api.on_render()
		header_x = 70 * ImGui.GetMainViewport().DpiScale
		size_x, size_y = ImGui.GetContentRegionAvail()
		local h1 = size_y * 0.7
		region = data_hander.cur_region()
		if not region then return end 

		ImGui.BeginChild("##chess_right_1", size_x, h1, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()
			if data_hander.is_multi_selected(region) then 
				-- 处理多选视图
			else
				local type, id, layerId = data_hander.get_first_selected(region)
				if type == "object" then 
					local gridData = data_hander.get_grid_data_by_uid(region, layerId, id)
					if gridData then 
						api.draw_checkbox_invisible(gridData)
						api.draw_inspec_bool(gridData, "hidden", "默认隐藏", "运行时是否默认隐藏")
						api.draw_inspec_float(gridData, "height", "高度", 0.01, "高度偏移")
						api.draw_inspec_float(gridData, "rotate", "旋转", 1, "物件旋转")
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
		ImGui.Text("不可见")
		ImGui.SameLineEx(header_x)
		local checkbox_value = {data_hander.is_invisible(region, gridData.id)}
		local change, v = ImGui.Checkbox("##checkbox_visible_obj", checkbox_value)
        if change then 
			if checkbox_value[1] then 
				data_hander.add_invisible(region, gridData.id)
			else 
				data_hander.remove_invisible(region, gridData.id)
			end
			stack.snapshoot(false)
		end
		api.show_tips("是否在编辑器中不可见，注意:这个选项不影响运行时")
	end

	function api.draw_inspec_bool(gridData, key, name, tip)
		ImGui.Text(name)
		ImGui.SameLineEx(header_x)
		local value = {gridData[key] or false}
		if ImGui.Checkbox("##inspec_checkbox_" .. key, value) then 
			if value then 
				gridData[key] = true 
			else 
				gridData[key] = nil
			end
			stack.snapshoot(true)
		end
		api.show_tips(tip)
	end

	function api.draw_inspec_float(gridData, key, name, speed, tip)
		ImGui.Text(name)
		ImGui.SameLineEx(header_x)
		ImGui.SetNextItemWidth(size_x - header_x - 20)
		local drag_value = {gridData[key] or 0}
		if ImGui.DragFloatEx("##drag_" .. key, drag_value, speed, nil, nil, "%.03f") then
			if drag_value[1] ~= 0 then 
				gridData[key] = drag_value[1]
			else 
				gridData[key] = nil
			end
			stack.snapshoot(true)
		end
		api.show_tips(tip)
	end

	function api.show_tips(tip)
		if tip and ImGui.IsItemHovered() then
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 5, 5)
			ImGui.SetTooltip(tip)
			ImGui.PopStyleVar()
		end
	end

	return api 
end


return {new = new}