--------------------------------------------------------
-- goap 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.goap.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.goap.renderer
	local api = {}
	local menu_name = "goap_drop_menu"
	local drop_from 
	local drop_to
	local cur_editor
	local input_buf = ImGui.StringBuf()

	---@type ly.game_editor.action.selector.api
	api.action_selector = require 'windows._other.wnd_action_selector'.new(editor)

	---@type ly.game_editor.tag.selector.api
	local tag_selector = require 'windows.tag.wnd_tag_selector'.new(editor)
	local item_len_x = 300

	local pop_setting_Id = "配置##pop_goap_setting"
	local tb_tag_files = {}
	local tb_attr_files = {}
	local cache_settings 	---@type ly.game_editor.goap.setting

	function api.set_data(data)
		stack.set_data_handler(data_hander)
		data_hander.set_data(data, api)
		stack.snapshoot(false)
	end

	local function draw_left(size_x)
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()

		for i, v in ipairs(data_hander.data.nodes) do 
			local label = string.format("%02d. %s##btn_goap_%d", i, v.name, i)
			local is_selected = data_hander.get_selected() == v.name
			local style = is_selected and GStyle.btn_left_selected or GStyle.btn_left

			if v == cur_editor then 
				ImGui.SetNextItemWidth(size_x - 10)
				if ImGui.InputTextEx("##input_name", input_buf, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue"}) or not is_selected then 
					local new_name = tostring(input_buf)
					if #new_name > 0 and new_name ~= v.name then
						if not data_hander.find_node(new_name) then 
							v.name = new_name
							stack.snapshoot(true)
						else 
							editor.msg_hints.show(string.format("%s 节点名字已经存在", new_name), "error")
						end
					end
					cur_editor = nil
				end
			else
				if editor.style.draw_style_btn(label, style, {size_x = size_x - 10}) then 
					if data_hander.set_selected(v.name) then 
						stack.snapshoot(false)
					end
				end

				if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
					cur_editor = v
					input_buf:Assgin(v.name)
				end

				if ImGui.BeginDragDropSource() then 
					data_hander.set_selected(v.name)
					dep.common.imgui_utils.SetDragDropPayload("DragGoap", v.name);
					ImGui.Text("正在拖动 " .. v.name);
					ImGui.EndDragDropSource();
				end

				if imgui_utils.GetDragDropPayload("DragGoap") and ImGui.BeginDragDropTarget() then 
					local payload = imgui_utils.AcceptDragDropPayload("DragGoap")
					if payload then
						ImGui.OpenPopup(menu_name, ImGui.PopupFlags { "None" });
						drop_from = payload
						drop_to = v.name
						data_hander.set_selected(v.name)
					end
					ImGui.EndDragDropTarget()
				end

				if ImGui.BeginPopupContextItem() then 
					if data_hander.set_selected(v.name) then stack.snapshoot(false) end 
					if ImGui.MenuItem("克 隆") then
						local node = data_hander.clone_node(v.name)
						data_hander.set_selected(node.name)
						stack.snapshoot(true)
					end
					if ImGui.MenuItem("删 除") then 
						data_hander.remove_node(v.name)
						stack.snapshoot(true)
					end
					ImGui.EndPopup()
				end
			end
		end

		if editor.style.draw_btn(" + ", false, {size_x = size_x - 10}) then 
			local node = data_hander.add_node(data_hander.next_name("node"))
			data_hander.set_selected(node.name)
			stack.snapshoot(true)
		end

		if ImGui.BeginPopupContextItemEx(menu_name) then 
			if ImGui.MenuItem("向前插入") then 
				local node1, idx1 = data_hander.find_node(drop_from)
				local node2, idx2 = data_hander.find_node(drop_to)
				data_hander.remove_node(node1.name)
				if idx1 < idx2 then 
					table.insert(data_hander.data.nodes, idx2 - 1, node1)
				else 
					table.insert(data_hander.data.nodes, idx2, node1)
				end
				data_hander.set_selected(node1.name)
				stack.snapshoot(true)
			end 
			if ImGui.MenuItem("向后插入") then 
				local node1, idx1 = data_hander.find_node(drop_from)
				local node2, idx2 = data_hander.find_node(drop_to)
				data_hander.remove_node(node1.name)
				if idx1 < idx2 then 
					table.insert(data_hander.data.nodes, idx2, node1)
				else 
					table.insert(data_hander.data.nodes, idx2 + 1, node1)
				end
				data_hander.set_selected(node1.name)
				stack.snapshoot(true)
			end 
			ImGui.EndPopup()
		end

		ImGui.EndGroup()
	end

	local head_len = 50
	---@param node ly.game_editor.goap.node
	local function draw_tag(node)
		ImGui.Text("激活:")
		ImGui.SameLineEx(head_len)
		local checkbox_value = {(not node.disable) and true or false}
		local change, v = ImGui.Checkbox("##btn_check_disable", checkbox_value)
		if change then 
			node.disable = not node.disable
			stack.snapshoot(true)
		end

		ImGui.Text("Tag:")
		ImGui.SameLineEx(head_len)
		ImGui.Text(node.tags and table.concat(node.tags, "; ") or "")
		ImGui.SameLine()
		if editor.style.draw_style_btn("编 辑##btn_tag_editor", GStyle.btn_normal) then 
			local path = data_hander.data.settings.tag
			if path and path ~= "" then
				---@type ly.game_editor.tag.selector.params
				local param = {}
				param.path = path
				param.is_multi = true
				param.selected = node.tags
				param.callback = function(list)
					node.tags = list
					stack.snapshoot(true)
				end
				tag_selector.open(param)
			else 
				editor.msg_hints.show("请先设置tag", "error")
			end
		end
	end

	---@param node ly.game_editor.goap.node
	local function draw_desc(node, size_x)
		ImGui.Text("描述:")
		ImGui.SameLineEx(head_len)
		ImGui.Text("描述内容")
	end

	---@param node ly.game_editor.goap.node
	local function draw_conditions(node, size_x)
		ImGui.Text("条件:")
		ImGui.SameLineEx(head_len)
		ImGui.BeginGroup()
		--ImGui.Dummy(10, 20)

		local draw_index = 0
		local max_depth = lib.get_table_depth(node.conditions)
		local function draw(list, idx, data, depth)
			draw_index = draw_index + 1
			local selected = data_hander.is_item_selected(node.id, "condition", data)
			local style = selected and GStyle.btn_left_selected or GStyle.btn_left
			local label = string.format("%s.%s  %s  %s ##btn_condition_%d", data[1] or "", data[2] or "", data[3] or "", data[4] or "", draw_index)
			local len = item_len_x + (max_depth - depth - 1) * 38 - 38
			if editor.style.draw_style_btn(label, style, {size_x = len}) then 
				if data_hander.set_selected_item(node, "condition", data) then 
					stack.snapshoot(false)
				end 
			end

			if ImGui.BeginPopupContextItem() then 
				if data_hander.set_selected_item(node, "condition", data) then 
					stack.snapshoot(false)
				end 
				if ImGui.MenuItem("前面插入条件") then
					table.insert(list, idx, {})
					stack.snapshoot(true)
				end
				if ImGui.MenuItem("后面插入条件") then
					table.insert(list, idx + 1, {})
					stack.snapshoot(true)
				end
				if idx > 2 and ImGui.MenuItem("上 移") then 
					data_hander.move_condition(node, data, -1)
					stack.snapshoot(true)
				end
				if idx < #list and ImGui.MenuItem("下 移") then 
					data_hander.move_condition(node, data, 1)
					stack.snapshoot(true)
				end
				if ImGui.MenuItem("and 扩展") then
					data[1] = "and"
					data[2] = {}
					data[3] = {}
					stack.snapshoot(true)
				end
				if ImGui.MenuItem("or 扩展") then
					data[1] = "or"
					data[2] = {}
					data[3] = {}
					stack.snapshoot(true)
				end
				if (depth > 0 or #list > 2) and ImGui.MenuItem("删 除") then 
					data_hander.delete_condition(node, data)
					stack.snapshoot(true)
				end
				ImGui.EndPopup()
			end
		end 

		local flag = ImGui.ComboFlags { "NoArrowButton" }
		local combo_index = 0;
		local function traverse(list, depth)
			local first = list[1]
			local type = first or "and"
			ImGui.SetNextItemWidth(30)
			combo_index = combo_index + 1
			if ImGui.BeginCombo("##condit_combo" .. combo_index, type, flag) then
				for i, name in ipairs({"and", "or"}) do
					if ImGui.Selectable(name, name == type) then
						list[1] = name
					end
				end
				ImGui.EndCombo()
			end
			ImGui.SameLine()
			ImGui.BeginGroup()
			for i = 2, #list do 
				local one = list[i]
				if _G.type(one) == 'table' then
					local first = one[1]
					if first == "and" or first == "or" then 
						traverse(one, depth + 1)
					else
						draw(list, i, one, depth) 
					end
				end
			end 
			ImGui.EndGroup()
		end 
		traverse(node.conditions, 0)
		ImGui.EndGroup()
	end

	---@param node ly.game_editor.goap.node
	local function draw_effect(node, size_x)
		ImGui.Dummy(5, 5)
		ImGui.Text("效果:")
		ImGui.SameLineEx(head_len)
		ImGui.BeginGroup()
		for i, v in ipairs(node.effects) do 
			local selected = data_hander.is_item_selected(node.id, "effect", i)
			local style = selected and GStyle.btn_left_selected or GStyle.btn_left
			local label = string.format("%s.%s  %s  %s ##btn_effect_%d", v[1] or "", v[2] or "", v[3] or "", v[4] or "", i)
			if editor.style.draw_style_btn(label, style, {size_x = item_len_x}) then 
				if data_hander.set_selected_item(node, "effect", i) then 
					stack.snapshoot(false)
				end 
			end
			if ImGui.BeginPopupContextItem() then 
				if data_hander.set_selected_item(node, "effect", i) then 
					stack.snapshoot(false)
				end 
				if i > 1 and ImGui.MenuItem("上 移") then
					table.insert(node.effects, i - 1, table.remove(node.effects, i))
					data_hander.set_selected_item(node, "effect", i - 1)
					stack.snapshoot(true)
				end
				if i < #node.effects and ImGui.MenuItem("下 移") then
					table.insert(node.effects, i + 1, table.remove(node.effects, i))
					data_hander.set_selected_item(node, "effect", i + 1)
					stack.snapshoot(true)
				end
				if ImGui.MenuItem("新 增") then
					data_hander.add_effect(node, i)
					data_hander.set_selected_item(node, "effect", i)
					stack.snapshoot(true)
				end
				if #node.effects > 1 and ImGui.MenuItem("删 除") then
					table.remove(node.effects, i)
					stack.snapshoot(true)
				end
				ImGui.EndPopup()
			end
		end 
		ImGui.EndGroup()
	end

	---@param node ly.game_editor.goap.node
	local function draw_actions(node, delta_time, size_x)
		ImGui.Dummy(5, 5)
		ImGui.Text("行为:")
		ImGui.SameLineEx(head_len)
		ImGui.SetNextItemWidth(120)
		if ImGui.BeginCombo("##body_type", node.body.type or "") then
			for i, name in ipairs({"lines", "sections", "fsm"}) do
				if ImGui.Selectable(name, name == node.body.type) then
					data_hander.set_body_type(node, name)
					stack.snapshoot(true)
				end
			end
			ImGui.EndCombo()
		end
		ImGui.Dummy(head_len - 8, 1)
		ImGui.SameLine()
		ImGui.BeginGroup()
		local body_handler = data_hander.get_body_handler(node)
		if body_handler then
			body_handler.draw(node, delta_time, size_x)
		else
			ImGui.Text("invalid type " .. tostring(node.body.type)) 
		end
		ImGui.EndGroup()
	end

	local function draw_center(size_x)
		local node = data_hander.get_selected_node()
		if not node then return end 

		ImGui.SetCursorPos(10, 10)
		ImGui.BeginGroup()
		draw_tag(node)
		draw_desc(node, size_x)
		draw_conditions(node, size_x)
		draw_effect(node, size_x)
		draw_actions(node, 0.05, size_x)
		ImGui.EndGroup()

		if ImGui.IsWindowHovered() and not ImGui.IsAnyItemHovered()  then 
			if ImGui.IsMouseReleased(ImGui.MouseButton.Left) then 
				data_hander.set_selected_item(node, nil, nil)
			end
		end
	end

	local function draw_detail(detail_x)
		local header_len = math.min(100, detail_x * 0.4)
		local content_len = detail_x - header_len - 20
		local data_def = editor.data_def
		local node = data_hander.get_selected_node()
		if not node then return end 

		local body_handler = data_hander.get_body_handler(node)
		---@type goap.action.data
		local action = body_handler and body_handler.get_selected_action(node)
		if action then 
			if not action.id then return end 
			local def = editor.tbParams.goap_mgr.find_action_def_by_id(action.id)
			if not def then 
				ImGui.TextColored(0.8, 0, 0, 1, string.format("invalid: %s", action.id))
				return
			end
			
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
			ImGui.SetCursorPos(5, 5)
			ImGui.BeginGroup()
			for i, param in ipairs(def.params) do 
				local v = action.params[param.key]
				if not v then 
					v = param.default
					action.params[param.key] = v
				end
				local draw_data = {value = v, header = param.desc, header_len = header_len, content_len = content_len}
				if data_def.show_inspector(param.type, draw_data) then 
					action.params[param.key] = draw_data.new_value
					stack.snapshoot(true)
				end
			end
			ImGui.EndGroup()
			ImGui.PopStyleVar()
			return
		end

		local type, v = data_hander.get_first_item_selected(node.id)
		local data
		if type == "effect" then 
			for i, _v in ipairs(node.effects) do 
				if i == v then 
					data = _v 
					break;
				end
			end 
		else
			data = v
		end 
		if not type or not data then return end 

		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()

		local draw_data = {value = data[1], header = "对象类型", header_len = header_len, content_len = content_len}
		draw_data.attr_handler = data_hander.attr_handler
		if data_def.show_inspector("attr_type", draw_data) then 
			data[1] = draw_data.new_value
			stack.snapshoot(true)
		end

		draw_data.new_value = nil
		draw_data.attr_type = data[1]
		draw_data.value = data[2]
		draw_data.header = "属性名字"
		if data_def.show_inspector("attr_key", draw_data) then 
			data[2] = draw_data.new_value
			stack.snapshoot(true)
		end

		if type == "effect" then 
			draw_data = {value = data[3], header = "数据操作", header_len = header_len, content_len = content_len}
			if data_def.show_inspector("data_opt", draw_data) then 
				data[3] = draw_data.new_value
				stack.snapshoot(true)
			end

		elseif type == "condition" then 
			draw_data = {value = data[3], header = "数据操作", header_len = header_len, content_len = content_len}
			if data_def.show_inspector("data_compare", draw_data) then 
				data[3] = draw_data.new_value
				stack.snapshoot(true)
			end
		end

		draw_data = {value = data[4], header = "操作值", header_len = header_len, content_len = content_len}
		if data_def.show_inspector("number", draw_data) then 
			data[4] = draw_data.new_value
			stack.snapshoot(true)
		end

		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	local function draw_pop_setting()
		if ImGui.BeginPopupModal(pop_setting_Id, true, ImGui.WindowFlags({})) then 
			local len = 400
			ImGui.SetCursorPos(20, 40)
			ImGui.BeginGroup()
			ImGui.Text("Tag定义:")
			ImGui.SameLine(100)
			ImGui.SetNextItemWidth(len)
			if ImGui.BeginCombo("##combo_tag", cache_settings.tag or "") then
				for i, name in ipairs(tb_tag_files) do
					if ImGui.Selectable(name, name == cache_settings.tag) then
						cache_settings.tag = name
					end
				end
				ImGui.EndCombo()
			end

			ImGui.Text("Attr定义:")
			ImGui.SameLine(100)
			ImGui.SetNextItemWidth(len)
			if ImGui.BeginCombo("##combo_attr", cache_settings.attr or "") then
				for i, name in ipairs(tb_attr_files) do
					if ImGui.Selectable(name, name == cache_settings.attr) then
						cache_settings.attr = name
					end
				end
				ImGui.EndCombo()
			end

			ImGui.EndGroup()
			ImGui.Dummy(30, 30)
			local pos_y = ImGui.GetCursorPosY()
			ImGui.SetCursorPos(200, pos_y)
			if editor.style.draw_btn(" 确 认 ##btn_ok", true, {size_x = 100}) then 
				local pre = data_hander.data.settings
				if pre.tag ~= cache_settings.tag or pre.attr ~= cache_settings.attr then 
					data_hander.modify_setting(cache_settings)
					stack.snapshoot(true)
				end
				ImGui.CloseCurrentPopup()
			end
			ImGui.SetCursorPos(450, 200)
			ImGui.Dummy(10, 10)
			ImGui.EndPopup()		
		end
	end

	function api.open_wnd_setting()
		ImGui.OpenPopup(pop_setting_Id)
		tb_tag_files = editor.files.get_all_file_by_ext("tag")
		tb_attr_files = editor.files.get_all_file_by_ext("attr")
		cache_settings = lib.copy(data_hander.data.settings)
	end

	function api.update(delta_time)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		if size_x <= 20 then return end 

		local left_x = 150
		local detail_x = math.min(300, size_x * 0.35)
		local center_x = size_x - left_x - detail_x

		ImGui.SetCursorPos(size_x - 100, 5)
		if editor.style.draw_btn("配 置##btn_goap_setting", false, {size_x = 80}) then 
			api.open_wnd_setting()
		end
		local pos_y = ImGui.GetCursorPosY()
		size_y = size_y - pos_y

		ImGui.SetCursorPos(0, pos_y)
		ImGui.BeginChild("pnl_left", left_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_left(left_x)
		ImGui.PopStyleVar()
		ImGui.EndChild()

		local node = data_hander.get_selected_node()
		if center_x <= 50 or not node or not data_hander.has_item_selected(node)  then 
			center_x = center_x + detail_x
			detail_x = 0
		end 
		if center_x <= 10 then return end 

		ImGui.SetCursorPos(left_x, pos_y)
		ImGui.BeginChild("pnl_center", center_x, size_y, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags({"HorizontalScrollbar"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_center(center_x)
		ImGui.PopStyleVar()
		ImGui.EndChild()

		if detail_x > 0 then 
			ImGui.SetCursorPos(size_x - detail_x, pos_y)
			ImGui.BeginChild("pnl_detail", detail_x, size_y, ImGui.ChildFlags({"Border"}))
			draw_detail(detail_x)
			ImGui.EndChild()
		end
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_pop_setting()
		tag_selector.update()
		api.action_selector.update()
		ImGui.PopStyleVar()
	end

	return api
end


return {new = new}