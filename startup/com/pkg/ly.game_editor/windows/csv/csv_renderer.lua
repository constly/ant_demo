--------------------------------------------------------
-- csv 窗口渲染
--------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils
local imgui_styles = dep.common.imgui_styles
local draw_list = dep.ImGuiExtend.draw_list

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.csv.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.csv.renderer
	local api = {}
	api.data_hander = data_hander
	api.stack = stack

	local refresh_width = false
	local table_index = 0;

	function api.set_data(data)
		data_hander.set_data(data)
		stack.set_data_handler(data_hander)
		stack.snapshoot()
	end

	local function draw_left()
		ImGui.BeginGroup()
		ImGui.Dummy(5, 2)
		local checkbox_value = {}
		local heads = data_hander.get_heads()
		if imgui_utils.draw_btn("全 选##btn_all", false, {size_x = 53}) then 
			for i, v in ipairs(heads) do 
				v.visible = true
				refresh_width = true
			end
			stack.snapshoot(false)
		end 
		ImGui.SameLine()
		if imgui_utils.draw_btn("清 空##btn_clear", false, {size_x = 53}) then 
			for i, v in ipairs(heads) do 
				v.visible = false
				refresh_width = true
			end
			stack.snapshoot(false)
		end 
		for i, v in ipairs(heads) do 
			checkbox_value[1] = v.visible
			local label = string.format("%s##checkbox_%s_i", v.key, v.key, i)
			local change, value = ImGui.Checkbox(label, checkbox_value)
			if change then 
				v.visible = checkbox_value[1]
				refresh_width = true
				stack.snapshoot(false)
			end
		end
		ImGui.EndGroup()
	end

	local function draw_body()
		local cols = data_hander.get_visbile_columns()
		if #cols == 0 then return end 

		local color_normal = ImGui.GetColorU32ImVec4(0.1, 0.1, 0.1, 1)
		local color_select = ImGui.GetColorU32ImVec4(0, 0.6, 0, 1)
		local function draw_cell(lineIdx, keyIdx, content, width, type)
			local label = string.format("%s##btn_cell_%d_%d", content, lineIdx, keyIdx )
			ImGui.TableSetBgColor(ImGui.TableBgTarget.CellBg, data_hander.is_selected(lineIdx, keyIdx) and color_select or color_normal)
			local ret = imgui_utils.draw_style_btn(label, imgui_styles.btn_transparency_center, {size_x = width}) 
			if ret then 
				data_hander.set_selected(lineIdx, keyIdx)
			end
			if type == "header" then 
				if ImGui.BeginPopupContextItem() then 
					if ImGui.MenuItem("复 制") then 
						print(1)
					end
					if ImGui.MenuItem("粘 贴") then 
						print(1)
					end
					if ImGui.MenuItem("插 入") then 
						print(1)
					end
					if ImGui.MenuItem("删 除") then 
						print(1)
					end
					if ImGui.MenuItem("清除内容") then 
						print(1)
					end
					ImGui.EndPopup()
				end
			end
			return ret
		end

		if refresh_width then table_index = table_index + 1 end 
		refresh_width = false

		ImGui.PushStyleVarImVec2(ImGui.StyleVar.CellPadding, 0, 0)
		ImGui.BeginTableEx("table_" .. table_index, #cols, ImGui.TableFlags {'Resizable', 'Borders', 'ScrollX', "ScrollY" })
		ImGui.TableSetupScrollFreeze(1, 1); 
		for i, col in ipairs(cols) do 
			ImGui.TableSetupColumnEx(col.key,  ImGui.TableColumnFlags {'WidthFixed'}, math.max(10, col.width or 10));
		end
		
		local y = 0
		for i, name in ipairs({"key", "type", "explain"}) do 
			ImGui.TableNextRow();
			y = y + 1
			for i, col in ipairs(cols) do 
				ImGui.TableSetColumnIndex(i - 1);
				if y == 1 then
					col.width = draw_list.GetTableColumnWidth(i - 1)
				end
				draw_cell(y, i, col[name], col.width, "header")
			end
		end
	
		local bodies = data_hander.get_bodies()
		for _, v in ipairs(bodies) do 
			y = y + 1
			ImGui.TableNextRow();
			for i, col in ipairs(cols) do 
				ImGui.TableSetColumnIndex(i - 1);
				local str = v[col.key] or ""
				draw_cell(y, i, str, col.width)
			end
		end

		ImGui.EndTable();
		ImGui.PopStyleVar()
	end

	local function draw_detail(detail_x)
		local cols = data_hander.get_visbile_columns()
		if #cols == 0 then return end 
		if data_hander.get_selected_count() ~= 1 then return end 

		local data_center = editor.data_center
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.SetCursorPos(5, 5)
		local header_len = math.min(100, detail_x * 0.4)
		local content_len = detail_x - header_len - 20
		ImGui.BeginGroup()

		local lineIdx, keyIdx = data_hander.get_first_selected()
		if lineIdx <= 3 then 
			local col = cols[keyIdx]
			if col then  
				local draw_data = {value = col.key, header = "key", active = lineIdx == 1, header_len = header_len, content_len = content_len}
				if data_center.show_inspector("string", draw_data) then 
					col.key = draw_data.new_value
					stack.snapshoot(true)
				end
				draw_data = {value = col.type, header = "数据类型",  active = lineIdx == 2, header_len = header_len, content_len = content_len}
				if data_center.show_inspector("data_type", draw_data) then 
					col.type = draw_data.new_value
					stack.snapshoot(true)
				end
				draw_data = {value = col.explain, header = "注释",  active = lineIdx == 3, header_len = header_len, content_len = content_len}
				if data_center.show_inspector("string", draw_data) then 
					col.explain = draw_data.new_value
					stack.snapshoot(true)
				end
			end 
		else 
			local line = data_hander.get_line_by_index(lineIdx - 3)
			if line then 
				local draw_data = {header = "key", header_len = header_len, content_len = content_len}
				for i, v in ipairs(cols) do 
					draw_data.value = line[v.key] or ""
					draw_data.header = v.key
					draw_data.active = i == keyIdx
					draw_data.header_tip = string.format("%s:%s - %s", v.key, v.type, v.explain or "")
					if data_center.show_inspector(v.type, draw_data) then 
						if not draw_data.new_value or draw_data.new_value == "" then 
							line[v.key] = nil
						else 
							line[v.key] = draw_data.new_value
						end
						stack.snapshoot(true)
					end
				end
			end
		end
		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	function api.update(delta_time)
		local all_x, size_y = ImGui.GetContentRegionAvail()
		local left_x = 120
		ImGui.BeginChild("left", left_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_left()
		ImGui.PopStyleVar()
		ImGui.EndChild()
		
		ImGui.SetCursorPos(left_x, 0)
		local size_x = all_x - left_x
		local detail_x = math.min(300, size_x * 0.35)
		if size_x <= 20 then return end 

		local content_x = size_x - detail_x;
		if content_x <= 70 then content_x = size_x end

		ImGui.BeginChild("content", content_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_body()
		ImGui.PopStyleVar()
		ImGui.EndChild()

		if content_x + detail_x == size_x then 
			ImGui.SetCursorPos(all_x - detail_x, 0)
			ImGui.BeginChild("detail", detail_x, size_y, ImGui.ChildFlags({"Border"}))
			draw_detail(detail_x)
			ImGui.EndChild()
		end
	end

	return api
end

return {new = new}