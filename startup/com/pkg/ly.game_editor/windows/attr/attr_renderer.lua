--------------------------------------------------------
-- attr 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.attr.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.attr.renderer
	local api = {}

	local menu_name = "##drop_menu_name"
	local drop_from, drop_to
	local pop_region_editor = "对象编辑##pop_region_editor"
	local cur_editor_region 	---@type ly.game_editor.attr.data.region
	local input_content = ImGui.StringBuf()

	function api.set_data(data)
		data_hander.set_data(data)
		stack.set_data_handler(data_hander)
		stack.snapshoot(false)
	end

	local function draw_content()
		local region = data_hander.get_selected_region()
		if not region then return end 
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()
		for i, v in ipairs(region.attrs) do 
			local is_selected = data_hander.get_selected_attr_id(region.id) == v.id
			local style = is_selected and GStyle.btn_left_selected or GStyle.btn_left
			local label = string.format("##btn_attr_%d", i)
			if editor.style.draw_style_btn(label, style, {size_x = 350}) then 
				data_hander.set_selected_attr(region.id, v.id)
			end

			if ImGui.BeginDragDropSource() then 
				data_hander.set_selected_attr(region.id, v.id)
				dep.common.imgui_utils.SetDragDropPayload("DragAttr", v.id);
				ImGui.Text("正在拖动 " .. v.id);
				ImGui.EndDragDropSource();
			end

			if imgui_utils.GetDragDropPayload("DragAttr") and ImGui.BeginDragDropTarget() then 
				local payload = imgui_utils.AcceptDragDropPayload("DragAttr")
				if payload then
					ImGui.OpenPopup(menu_name, ImGui.PopupFlags { "None" });
					drop_from = payload
					drop_to = v.id
					data_hander.set_selected_attr(region.id, v.id)
				end
				ImGui.EndDragDropTarget()
			end

			if ImGui.BeginPopupContextItem() then 
				data_hander.set_selected_attr(region.id, v.id)
				if ImGui.MenuItem("克 隆") then
					data_hander.clone_attr(region.id, v.id)
					stack.snapshoot(true)
				end
				if ImGui.MenuItem("删 除") then 
					data_hander.remove_attr(region.id, v.id)
					stack.snapshoot(true)
				end
				ImGui.EndPopup()
			end

			ImGui.SameLineEx(10)
			ImGui.Text(string.format("%s : %s", v.type, v.id))
			ImGui.SameLineEx(200)
			ImGui.Text(v.name or "")
			ImGui.SameLineEx(360)
			ImGui.Text(v.desc or "")
		end
		if editor.style.draw_btn(" + ##btn_add", false, {size_x = 60}) then 
			local name = data_hander.next_attr_id(region.id, "attr")
			data_hander.add_attr(region.id, name)
			stack.snapshoot(true)
		end

		if ImGui.BeginPopupContextItemEx(menu_name) then 
			local region = data_hander.get_selected_region()
			local function swap(offset)
				local attr1, idx1 = data_hander.get_attr(region.id, drop_from)
				local attr2, idx2 = data_hander.get_attr(region.id, drop_to)
				if attr1 and attr2 then 
					data_hander.remove_attr(region.id, drop_from)
					table.insert(region.attrs, idx1 < idx2 and (idx2 - 1 + offset) or (idx2 + offset), attr1)
					data_hander.set_selected_attr(region.id, drop_from)
					stack.snapshoot(true)
				end
			end
			if region and ImGui.MenuItem("拖动到前面") then 
				swap(0)
			end
			if region and ImGui.MenuItem("拖动到后面") then 
				swap(1)
			end
			ImGui.EndPopup()
		end

		ImGui.EndGroup()
	end

	local function draw_detail(detail_x)
		local region = data_hander.get_selected_region()
		if not region then return end 
		local attr = data_hander.get_attr(region.id, data_hander.get_selected_attr_id(region.id))
		if not attr then return end 

		local data_def = editor.data_def
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()

		local header_len = math.min(100, detail_x * 0.4)
		local content_len = detail_x - header_len - 20

		local draw_data = {value = attr.id, header = "变量名(ID)", header_len = header_len, content_len = content_len}
		if data_def.show_inspector("string", draw_data) then 
			if not data_hander.get_attr(region.id, draw_data.new_value) then 
				attr.id = draw_data.new_value
				data_hander.set_selected_attr(region.id, attr.id)
				stack.snapshoot(true)
			else 
				editor.msg_hints.show(string.format("变量名:%s 已经存在", draw_data.new_value), "error")
			end
		end

		draw_data = {value = attr.type, header = "变量类型", header_len = header_len, content_len = content_len}
		if data_def.show_inspector("data_type", draw_data) then 
			attr.type = draw_data.new_value
			stack.snapshoot(true)
		end

		draw_data = {value = attr.name, header = "中文名字", header_len = header_len, content_len = content_len}
		if data_def.show_inspector("string", draw_data) then 
			attr.name = draw_data.new_value
			stack.snapshoot(true)
		end

		draw_data = {value = attr.desc, header = "变量说明", header_len = header_len, content_len = content_len}
		if data_def.show_inspector("string", draw_data) then 
			attr.desc = draw_data.new_value
			stack.snapshoot(true)
		end

		-- draw_data = {value = attr.category, header = "变量分类", header_len = header_len, content_len = content_len}
		-- if data_def.show_inspector("string", draw_data) then 
		-- 	attr.category = draw_data.new_value
		-- 	stack.snapshoot(true)
		-- end

		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	local function draw_pop_region_editor(need_open)
		if need_open then 
			ImGui.OpenPopup(pop_region_editor)
		end
		if ImGui.BeginPopupModal(pop_region_editor, true, ImGui.WindowFlags({})) then 
			local len = 300
			ImGui.SetCursorPos(20, 40)
			ImGui.BeginGroup()

			ImGui.Text("对象名字:")
			ImGui.SameLineEx()
			
			ImGui.PushItemWidth(len)
			local flag = ImGui.InputTextFlags { "CharsNoBlank", "AutoSelectAll" } 
			input_content:Assgin(cur_editor_region.id)
			if ImGui.InputText("##input_object_name", input_content, flag) then 
				cur_editor_region.id = tostring(input_content) or ""
			end
			ImGui.PopItemWidth()

			ImGui.Text("对象描述:")
			ImGui.SameLine()
			ImGui.PushItemWidth(len)
			input_content:Assgin(cur_editor_region.desc or "")
			if ImGui.InputText("##input_object_desc", input_content) then 
				cur_editor_region.desc = tostring(input_content) or ""
			end
			ImGui.PopItemWidth()

			ImGui.EndGroup()
			ImGui.Dummy(30, 30)
			local pos_y = ImGui.GetCursorPosY()
			ImGui.SetCursorPos(150, pos_y)
			if editor.style.draw_btn(" 确 认 ##btn_ok", true, {size_x = 100}) then 
				local region = data_hander.get_selected_region()
				local try = data_hander.get_region(cur_editor_region.id)
				if try and try ~= region then 
					editor.msg_hints.show("名字已经存在", "error")
				else 
					if region.id ~= cur_editor_region.id or region.desc ~= cur_editor_region.desc then 
						region.id = cur_editor_region.id
						region.desc = cur_editor_region.desc
						data_hander.set_selected_region(region.id)
						stack.snapshoot(true)
					end
					ImGui.CloseCurrentPopup()
				end
			end
			ImGui.SetCursorPos(400, 200)
			ImGui.Dummy(10, 10)

			ImGui.EndPopup()
		end 
	end

	function api.update()
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.SetCursorPos(6, 5)
		ImGui.BeginGroup()
		local open_editor
		for i, v in ipairs(data_hander.data.regions) do 
			local label = string.format("%s##btn_region_%d", v.id, i)
			local is_selected = data_hander.get_selected_region_id() == v.id
			if editor.style.draw_btn(label, is_selected) then 
				if data_hander.set_selected_region(v.id) then 
					stack.snapshoot(false)
				end
			end 
			if v.desc and v.desc ~= "" and ImGui.BeginItemTooltip() then 
				ImGui.Text(v.desc)
				ImGui.EndTooltip()
			end
			if ImGui.BeginPopupContextItem() then 
				data_hander.set_selected_region(v.id)
				if ImGui.MenuItem("编 辑") then
					open_editor = true
					cur_editor_region = lib.copy(v)
				end
				if ImGui.MenuItem("删 除") then 
					data_hander.remove_region(v.id)
					stack.snapshoot(true)
				end
				ImGui.EndPopup()
			end
			ImGui.SameLine()
		end 
		if editor.style.draw_btn("  +  ##btn_region_add") then 
			local region = data_hander.add_region(data_hander.next_region_id("object"))
			data_hander.set_selected_region(region.id)
			stack.snapshoot(true)
		end
		draw_pop_region_editor(open_editor)
		ImGui.EndGroup()
		local pos_x, pos_y = ImGui.GetCursorPos()
		local size_x, size_y = ImGui.GetContentRegionAvail();
		local detal_x = data_hander.get_selected_attr() and 250 or 0
		local content_x = size_x - detal_x
		ImGui.BeginChild("content", content_x, size_y, ImGui.ChildFlags({"Border"}))
		draw_content()
		ImGui.EndChild()

		if detal_x > 0 then
			ImGui.SameLine()
			ImGui.SetCursorPos(content_x, pos_y)
			ImGui.BeginChild("detail", detal_x, size_y, ImGui.ChildFlags({"Border"}))
			draw_detail(detal_x)
			ImGui.EndChild()
		end
		ImGui.PopStyleVar()
	end

	return api
end 

return {new = new}