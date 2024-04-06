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

	function api.set_data(data)
		stack.set_data_handler(data_hander)
		data_hander.set_data(data)
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
		ImGui.EndGroup()

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
		ImGui.Text("Npc Skill Room")
		ImGui.SameLine()
		if editor.style.draw_style_btn("编 辑##btn_tag_editor", GStyle.btn_normal) then 
			
		end
	end

	---@param node ly.game_editor.goap.node
	local function draw_enable(node)
		

		ImGui.Text("描述:")
		ImGui.SameLineEx(head_len)
		ImGui.Text("描述内容")
	end

	local function draw_center(size_x)
		local node = data_hander.get_selected_node()
		if not node then return end 

		ImGui.SetCursorPos(10, 10)
		ImGui.BeginGroup()
		draw_tag(node)
		draw_enable(node)

		
		ImGui.Text("条件:")
		ImGui.Text("效果:")
		ImGui.Text("节点:")
		ImGui.EndGroup()
	end

	local function draw_detail(size_x)

	end

	function api.update(delta_time)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		if size_x <= 20 then return end 

		local left_x = 150
		local detail_x = math.min(300, size_x * 0.35)
		local center_x = size_x - left_x - detail_x

		ImGui.BeginChild("pnl_left", left_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_left(left_x)
		ImGui.PopStyleVar()
		ImGui.EndChild()

		if center_x <= 50 or not data_hander.get_selected() then 
			center_x = center_x + detail_x
			detail_x = 0
		end 
		if center_x <= 10 then return end 

		ImGui.SetCursorPos(left_x, 0)
		ImGui.BeginChild("pnl_center", center_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_center(center_x)
		ImGui.PopStyleVar()
		ImGui.EndChild()

		if detail_x > 0 then 
			ImGui.SetCursorPos(size_x - detail_x, 0)
			ImGui.BeginChild("pnl_detail", detail_x, size_y, ImGui.ChildFlags({"Border"}))
			draw_detail(detail_x)
			ImGui.EndChild()
		end
	end

	return api
end


return {new = new}