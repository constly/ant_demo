--------------------------------------------------------
-- csv 窗口渲染
--------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui
local lib = dep.common.lib
local imgui_styles = dep.common.imgui_styles
local draw_list = dep.ImGuiExtend.draw_list

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.csv.handler
---@param stack common_data_stack
---@param clipboard ly.game_editor.csv.clipboard
local function new(editor, data_hander, stack, clipboard)
	---@class ly.game_editor.csv.renderer
	local api = {}
	api.data_hander = data_hander
	api.stack = stack

	local show_left = false
	local color_edit_flag = ImGui.ColorEditFlags { "Float", "NoInputs" } 
	local refresh_width = false
	local table_index = 0;
	local random_id = math.random(1 << 32)
	local input_x, input_y
	local input_buf = ImGui.StringBuf()
	local line_y = 30
	function api.set_data(data)
		data_hander.set_data(data)
		stack.set_data_handler(data_hander)
		stack.snapshoot()
	end

	local function draw_left()
		ImGui.SetCursorPos(3, 0)
		ImGui.BeginGroup()
		ImGui.Dummy(5, 2)
		local checkbox_value = {}
		local heads = data_hander.get_heads()
		if editor.style.draw_btn("全 选##btn_all", false, {size_x = 53}) then 
			for i, v in ipairs(heads) do 
				v.visible = true
				refresh_width = true
			end
			stack.snapshoot(false)
		end 
		ImGui.SameLine()
		if editor.style.draw_btn("清 空##btn_clear", false, {size_x = 53}) then 
			for i, v in ipairs(heads) do 
				v.visible = false
				refresh_width = true
			end
			stack.snapshoot(false)
		end 
		line_y = ImGui.GetCursorPosY()
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

	local function keyIdx_to_columnIdx(keyIdx)
		local cols = data_hander.get_visbile_columns()
		local col = cols[keyIdx]
		if not col then return end 
		local v, index = data_hander.get_colume(col.key)
		return index
	end
	
	---@param col ly.game_editor.csv.head
	local function draw_cell(lineIdx, keyIdx, content, col)
		local width = col.width
		local is_selected = data_hander.is_selected(lineIdx, keyIdx)
		local btn_style  
		if lineIdx == 1 then 
			btn_style = is_selected and GStyle.cell_selected or GStyle.cell_header
		else 
			btn_style = is_selected and GStyle.cell_selected or GStyle.cell_body 
		end
		local ret 
		if col.type == "color" and lineIdx >= 4 then 
			local label = string.format("##btn_cell_%d_%d", lineIdx, keyIdx )
			local tb = lib.string_to_color_array(content)
			ImGui.SetNextItemWidth(width * 0.5)
			if ImGui.ColorEdit4(label, tb, color_edit_flag) then 
				local get = function(idx) return lib.float_format(tb[idx], 3) end
				content = string.format("{%s,%s,%s,%s}", get(1), get(2), get(3), get(4))
			end
			ImGui.SameLine()
			label = string.format("##btn_cell_%d_%d_h", lineIdx, keyIdx )
			ret = editor.style.draw_style_btn(label, btn_style, {size_x = width * 0.5}) 
		else
			if keyIdx == input_x and lineIdx == input_y then 
				ImGui.SetNextItemWidth(width)
				local style<close> = editor.style.use(GStyle.cell_input)
				if ImGui.InputText("##tabel_input_cell", input_buf, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue"}) or not is_selected then 
					input_x, input_y = nil, nil
					return tostring(input_buf)
				end
				return content
			end
			local label = string.format("%s##btn_cell_%d_%d", content, lineIdx, keyIdx )
			ret = editor.style.draw_style_btn(label, btn_style, {size_x = width}) 
		end
		if ret then 
			local ok = true
			if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
				data_hander.add_selected(lineIdx, keyIdx)
			elseif ImGui.IsKeyDown(ImGui.Key.LeftShift) then 
				data_hander.add_selected_shift(lineIdx, keyIdx)
			else
				ok = data_hander.set_selected(lineIdx, keyIdx)
			end
			if ok then 
				stack.snapshoot(false)
			end
		end
		if lineIdx > 2 and ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
			input_x = keyIdx
			input_y = lineIdx
			input_buf:Assgin(tostring(content or ""))
		end
		if lineIdx == 1 then 
			if ImGui.BeginPopupContextItem() then 
				if not is_selected then 
					data_hander.set_selected(lineIdx, keyIdx)
					stack.snapshoot(false)
				end
				if ImGui.MenuItem("复 制") then 
					clipboard.copy()
				end
				if ImGui.MenuItem("粘 贴") then 
					if clipboard.paste() then 
						stack.snapshoot(true)
					end
				end
				if ImGui.MenuItem("删 除") then 
					data_hander.delete_selected()
					stack.snapshoot(true)
				end
				if ImGui.MenuItem("清除内容") then 
					data_hander.clear_selected()
					stack.snapshoot(true)
				end
				local n = data_hander.get_selected_count()
				if n <= 1 then
					if keyIdx > 1 and ImGui.MenuItem("向前插入列") then 
						local index = keyIdx_to_columnIdx(keyIdx)
						local key = data_hander.gen_next_column_key("key")
						data_hander.insert_column(key, "string", index, "注释")
						stack.snapshoot(true)
					end
					if ImGui.MenuItem("向后插入列") then 
						local index = keyIdx_to_columnIdx(keyIdx)
						local key = data_hander.gen_next_column_key("key")
						data_hander.insert_column(key, "string", index + 1, "注释")
						stack.snapshoot(true)
					end
				end
				ImGui.EndPopup()
			end
		else 
			if ImGui.BeginPopupContextItem() then 
				if not is_selected then 
					data_hander.set_selected(lineIdx, keyIdx)
					stack.snapshoot(false)
				end
				if ImGui.MenuItem("复 制") then 
					print(1)
				end
				if ImGui.MenuItem("剪 切") then 
					print(1)
				end
				if ImGui.MenuItem("粘 贴") then 
					print(1)
				end
				if ImGui.MenuItem("清 除") then 
					data_hander.clear_selected()
					stack.snapshoot(true)
				end
				local n = data_hander.get_selected_count()
				if n <= 1 then
					if ImGui.BeginMenu("向上插入行") then 
						if ImGui.MenuItem("插入1行") then 
							data_hander.insert_line(lineIdx - 3, 1)
							stack.snapshoot(true)
						end
						if ImGui.MenuItem("插入5行") then 
							data_hander.insert_line(lineIdx - 3, 5)
							stack.snapshoot(true)
						end
						if ImGui.MenuItem("插入10行") then 
							data_hander.insert_line(lineIdx - 3, 10)
							stack.snapshoot(true)
						end
						ImGui.EndMenu();
					end
					if ImGui.BeginMenu("向下插入行") then 
						if ImGui.MenuItem("插入1行") then 
							data_hander.insert_line(lineIdx - 2, 1)
							stack.snapshoot(true)
						end
						if ImGui.MenuItem("插入5行") then 
							data_hander.insert_line(lineIdx - 2, 5)
							stack.snapshoot(true)
						end
						if ImGui.MenuItem("插入10行") then 
							data_hander.insert_line(lineIdx - 2, 10)
							stack.snapshoot(true)
						end
						ImGui.EndMenu();
					end
				end
				ImGui.EndPopup()
			end
		end
		return content
	end

	local function draw_body()
		local cols = data_hander.get_visbile_columns()
		if #cols == 0 then return end 
		if refresh_width then table_index = table_index + 1 end 
		refresh_width = false

		local label = string.format("table_%s_%s", random_id, table_index)
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.CellPadding, 0, 0)
		if ImGui.BeginTableEx(label, #cols + 2, ImGui.TableFlags {'Resizable', 'Borders', 'ScrollX', "ScrollY" }) then
			ImGui.TableSetupScrollFreeze(2, 1); 
			ImGui.TableSetupColumnEx("",  ImGui.TableColumnFlags {'WidthFixed'}, 30);
			for i, col in ipairs(cols) do 
				ImGui.TableSetupColumnEx(col.key,  ImGui.TableColumnFlags {'WidthFixed'}, math.max(10, col.width or 10));
			end
			ImGui.TableSetupColumnEx("",  ImGui.TableColumnFlags {'WidthFixed'}, 60);
			
			local y = 0
			for i, name in ipairs({"key", "type", "explain"}) do 
				ImGui.TableNextRow();
				y = y + 1
				for i, col in ipairs(cols) do 
					ImGui.TableSetColumnIndex(i);
					if y == 1 then
						col.width = draw_list.GetTableColumnWidth(i)
					end
					local str = draw_cell(y, i, col[name], col)
					if str ~= col[name] then 
						col[name] = str
						stack.snapshoot(true)
					end
				end
				if y == 1 then 
					ImGui.TableSetColumnIndex(#cols + 1);
					local width = draw_list.GetTableColumnWidth(#cols + 1)
					if editor.style.draw_style_btn("+##btn_table_add_column", GStyle.btn_transp_center, {size_x = width}) then 
						local key = data_hander.gen_next_column_key("key")
						data_hander.insert_column(key, "string", nil, "注释")
						stack.snapshoot(true)
					end
				end
			end
		
			local bodies = data_hander.get_bodies()
			for _, v in ipairs(bodies) do 
				y = y + 1
				ImGui.TableNextRow();
				ImGui.TableSetColumnIndex(0);
				ImGui.Text(string.format(" %d", y - 3))
				for i, col in ipairs(cols) do 
					ImGui.TableSetColumnIndex(i);
					local str = v[col.key] or ""
					local new = draw_cell(y, i, str, col)
					if new ~= str then 
						v[col.key] = new
						stack.snapshoot(true)
					end
				end
			end
			ImGui.TableNextRow();
			ImGui.TableSetColumnIndex(0);
			local width = draw_list.GetTableColumnWidth(0)
			if editor.style.draw_style_btn("+ ##btn_table_add_line", GStyle.btn_transp_center, {size_x = width}) then 
				data_hander.insert_line()
				stack.snapshoot(true)
			end
			ImGui.EndTable();
		end
		ImGui.PopStyleVar()
	end

	local function draw_detail(detail_x)
		local cols = data_hander.get_visbile_columns()
		if #cols == 0 then return end 
		if data_hander.get_selected_count() ~= 1 then return end 

		local lineIdx, keyIdx = data_hander.get_first_selected()
		local col = cols[keyIdx]
		if not col then return end 
		
		local data_def = editor.data_def
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.BeginGroup()

		local header_len = 120
		local content_len = 200
		local content_len2 = math.max(content_len, detail_x - 300)
		if lineIdx <= 3 then 
			if lineIdx == 1 then 
				local draw_data = {value = col.key, header = "关键字", header_len = header_len, content_len = content_len}
				if data_def.show_inspector("string", draw_data) then 
					if not data_hander.is_key_exist(draw_data.new_value) then
						data_hander.notify_modify_key(col.key, draw_data.new_value)
						col.key = draw_data.new_value
						stack.snapshoot(true)
					else 
						editor.msg_hints.show(draw_data.new_value .. "已经存在", "error")
					end
				end
			elseif lineIdx == 2 then 
				local draw_data = {value = col.type, header = "数据类型", header_len = header_len, content_len = content_len}
				if data_def.show_inspector("data_type", draw_data) then 
					col.type = draw_data.new_value
					stack.snapshoot(true)
				end
			elseif lineIdx == 3 then 
				local draw_data = {value = col.explain, header = "注释说明", header_len = header_len, content_len = content_len2}
				if data_def.show_inspector("string", draw_data) then 
					col.explain = draw_data.new_value
					stack.snapshoot(true)
				end
			end
		else 
			local line = data_hander.get_line_by_index(lineIdx - 3)
			local draw_data = {header = "key", header_len = header_len}
			draw_data.value = line[col.key] or ""
			draw_data.header = col.key
			draw_data.content_len = col.type == "string" and content_len2 or content_len
			draw_data.header_tip = string.format("%s:%s - %s", col.key, col.type, col.explain or "")
			if data_def.show_inspector(col.type, draw_data) then 
				if not draw_data.new_value or draw_data.new_value == "" then 
					line[col.key] = nil
				else 
					line[col.key] = draw_data.new_value
				end
				stack.snapshoot(true)
			end
		end

		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	function api.update(delta_time)
		local all_x, size_y = ImGui.GetContentRegionAvail()
		local left_x = 120
		if not show_left then left_x = 0 end
		if left_x > 0 then
			ImGui.BeginChild("left", left_x, size_y, ImGui.ChildFlags({"Border"}))
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
			draw_left()
			ImGui.PopStyleVar()
			ImGui.EndChild()
		end

		ImGui.SetCursorPos(left_x, line_y)
		local size_x = all_x - left_x
		ImGui.BeginChild("content", size_x, size_y - line_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_body()
		ImGui.PopStyleVar()
		ImGui.EndChild()

		ImGui.SetCursorPos(left_x + 3, 5)
		if show_left then
			if editor.style.draw_btn(" << ##btn_left_1", true) then 
				show_left = false
			end
		else 
			if editor.style.draw_btn(" >> ##btn_left_2", true) then 
				show_left = true
			end
		end
		ImGui.SameLine()
		draw_detail(size_x)
	end

	return api
end

return {new = new}