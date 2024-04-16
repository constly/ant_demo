--------------------------------------------------------
-- tag 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor ly.game_editor.editor
---@param data_hander ly.game_core.tag.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.tag.renderer
	local api = {}

	local size_x
	local cur_editor_name
	local input_buf = ImGui.StringBuf()
	local input_desc_buf = ImGui.StringBuf()
	local menu_name = "menu_tag_drop_complete"
	local drop_from
	local drop_to
	local is_add

	local function depth_to_str(n)
		n = n or 1
		local tb = {}
		for i = 1, n do 
			table.insert(tb, "")
		end
		return table.concat(tb, "        ")
	end

	local function set_editor_content(name, desc, _is_add)
		cur_editor_name = name
		is_add = _is_add
		input_buf:Assgin(name)
		input_desc_buf:Assgin(desc or "")
	end

	---@param data ly.game_core.tag.data
	local function draw_item(data, depth)
		local selected = data_hander.get_first_selected() == data.name
		local style = selected and GStyle.tag_active or GStyle.tag_normal
		local desc = (data.desc and data.desc ~= "") and string.format("(%s)", data.desc) or ""
		local str = string.format("%s%s %s##btn_tag_%s", depth_to_str(depth), data.name, desc, data.name)
		if data.name == cur_editor_name then 
			ImGui.SetNextItemWidth(250)
			if ImGui.InputTextEx("##input_name", input_buf, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue"}) then 
			end
			ImGui.SameLine()
			ImGui.SetNextItemWidth(250)
			if ImGui.InputTextWithHint("##input_desc", "表情描述", input_desc_buf, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue"}) then 
				
			end
			ImGui.SameLine()
			if editor.style.draw_btn(" 确 认 ##btn_tag_ok", false, {size_x = 120}) then 
				local name = tostring(input_buf)
				data.desc = tostring(input_desc_buf)
				if not data_hander.is_tag_exist(name) then 
					data_hander.rename(data.name, name)
					data_hander.set_selected(name)
				elseif name ~= data.name then 
					editor.msg_hints.show(string.format("tag %s 已经存在", name), "error")
				end
				cur_editor_name = nil
				stack.snapshoot(true)
			end
			if not is_add then
				ImGui.SameLine()
				if editor.style.draw_btn(" 取 消 ##btn_tag_cancel", false, {size_x = 120}) then 
					cur_editor_name = nil
				end
			end
		else
			if editor.style.draw_style_btn(str, style, {size_x = size_x}) then 
				data_hander.set_selected(data.name)
			end

			if ImGui.BeginDragDropSource() then 
				data_hander.set_selected(data.name)
				dep.common.imgui_utils.SetDragDropPayload("DragTag", data.name);
				ImGui.Text("正在拖动 " .. data.name);
				ImGui.EndDragDropSource();
			end

			if imgui_utils.GetDragDropPayload("DragTag") and ImGui.BeginDragDropTarget() then 
				local payload = imgui_utils.AcceptDragDropPayload("DragTag")
				if payload then
					ImGui.OpenPopup(menu_name, ImGui.PopupFlags { "None" });
					drop_from = payload
					drop_to = data.name
					data_hander.set_selected(data.name)
				end
				ImGui.EndDragDropTarget()
			end

			if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
				set_editor_content(data.name, data.desc, false)
			end

			if ImGui.BeginPopupContextItem() then 
				if data_hander.set_selected(data.name) then stack.snapshoot(false) end 
				if ImGui.MenuItem("新增子节点") then
					local name = data_hander.get_next_name("new_tag")
					if name then 
						data_hander.add_tag(name, data, 1)
						data_hander.set_selected(name)
						set_editor_content(name, "", true)
					end
					stack.snapshoot(true)
				end
				if ImGui.MenuItem("删 除") then 
					data_hander.remove_tag(data.name)
					stack.snapshoot(true)
				end
				ImGui.EndPopup()
			end
		end

		for i, v in ipairs(data.children) do 
			draw_item(v, depth + 1)
		end
	end

	function api.set_data(data)
		stack.set_data_handler(data_hander)
		data_hander.set_data(data)
		stack.snapshoot(false)
	end

	function api.update(delta_time)
		size_x = ImGui.GetContentRegionAvail()
		size_x = size_x - 50

		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.SetCursorPos(10, 5)
		ImGui.BeginGroup()

		for i, v in ipairs(data_hander.data.children) do 
			draw_item(v, 1)
		end

		if editor.style.draw_btn(" 新 增 ", false, {size_x = 120}) then 
			local name = data_hander.get_next_name("new_tag")
			if name then 
				data_hander.add_tag(name)
				data_hander.set_selected(name)
				set_editor_content(name, "", true)
				stack.snapshoot(true)
			end
		end

		if ImGui.BeginPopupContextItemEx(menu_name) then 
			if ImGui.MenuItem("互相交换") then 
				local node1 = data_hander.find_by_name(drop_from)
				local node2 = data_hander.find_by_name(drop_to)
				if node1 and node2 and node1 ~= node2 then 
					node1.name, node2.name = node2.name, node1.name
					stack.snapshoot(true)
				end
			end
			if ImGui.MenuItem("设置为其子节点") then 
				local node1 = data_hander.find_by_name(drop_from)
				local node2 = data_hander.find_by_name(drop_to)
				if node1 and node2 and node1 ~= node2 then 
					data_hander.remove_tag(drop_from)
					table.insert(node2.children, 1, node1)
					data_hander.set_selected(drop_from)
					stack.snapshoot(true)
				end
			end
			if ImGui.MenuItem("设置为平级节点(前)") then 
				local parent, idx = data_hander.get_parent(drop_to)
				local node1 = data_hander.find_by_name(drop_from)
				local node2 = data_hander.find_by_name(drop_to)
				if parent and node1 and node2 and node1 ~= node2 then 
					data_hander.remove_tag(drop_from)
					table.insert(parent.children, idx, node1)
					data_hander.set_selected(drop_from)
					stack.snapshoot(true)
				end
			end
			if ImGui.MenuItem("设置为平级节点(后)") then 
				local parent, idx = data_hander.get_parent(drop_to)
				local node1 = data_hander.find_by_name(drop_from)
				local node2 = data_hander.find_by_name(drop_to)
				if parent and node1 and node2 and node1 ~= node2 then 
					data_hander.remove_tag(drop_from)
					if idx >= #parent.children then 
						table.insert(parent.children, node1)
					else 
						table.insert(parent.children, idx + 1, node1)
					end
					data_hander.set_selected(drop_from)
					stack.snapshoot(true)
				end
			end
			ImGui.EndPopup();
		end

		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	return api
end 

return {new = new}