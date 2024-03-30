--------------------------------------------------------
-- ini 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local imgui_utils = dep.common.imgui_utils
local imgui_styles = dep.common.imgui_styles
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.ini.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.ini.renderer
	local api = {}
	local len_x = 350
	local content_x

	---@param region ly.game_editor.ini.region
	local function draw_region(index, region)
		ImGui.PushIDInt(index)
		ImGui.SetCursorPosX(10)
		ImGui.BeginGroup()
		local selected_region, selected_key = data_hander.get_selected()
		local style = (selected_region == region.name and not selected_key) and imgui_styles.btn_blue or imgui_styles.btn_normal_item
		if imgui_utils.draw_style_btn(region.name, style, {size_x = len_x}) then 
			if data_hander.set_selected(region.name) then stack.snapshoot(false) end
		end
		if ImGui.BeginPopupContextItem() then
			if data_hander.set_selected(region.name) then stack.snapshoot(false) end
			if ImGui.MenuItem("新建 Item") then 
				local key = data_hander.gen_next_item_name(region.name, "new item")
				if data_hander.add_item(region.name, key) then 
					data_hander.set_selected(region.name, key)
					stack.snapshoot(true)
				end
			end
			if ImGui.MenuItem("删 除 ") then 
				if data_hander.delte_region(region.name) then 
					stack.snapshoot(true)
				end
			end
			if ImGui.MenuItem("克 隆 ") then 
				local new = data_hander.clone_region(region.name, index + 1)
				if new then 
					data_hander.set_selected(new.name)
					stack.snapshoot(true)
				end
			end
			ImGui.EndPopup()
		end
		if ImGui.BeginDragDropSource() then 
			if data_hander.set_selected(region.name, region.name) then stack.snapshoot(false) end 
			imgui_utils.SetDragDropPayload("DrapIniRegion", region.name);
			ImGui.Text("正在拖动 " .. region.name);
			ImGui.EndDragDropSource();
		end

		if imgui_utils.GetDragDropPayload("DrapIniRegion") and ImGui.BeginDragDropTarget() then 
			local payload = imgui_utils.AcceptDragDropPayload("DrapIniRegion")
			if data_hander.drag_region(payload, region.name) then 
				stack.snapshoot(true)
			end
			ImGui.EndDragDropTarget()
		end
		if region.desc and region.desc ~= "" then
			ImGui.SameLine()
			ImGui.TextColored(0, 0.8, 0, 1, region.desc)
		end

		for i, item in ipairs(region.items) do 
			local style_name = (selected_region == region.name and selected_key == item.key) and imgui_styles.btn_blue or imgui_styles.btn_normal_item
			local style<close> = imgui_styles.use(style_name)
			local label = string.format("##btn_item_%d", i)
			if ImGui.ButtonEx(label, len_x) then 
				if data_hander.set_selected(region.name, item.key) then stack.snapshoot(false) end 
			end
			if ImGui.BeginPopupContextItem() then 
				if data_hander.set_selected(region.name, item.key) then stack.snapshoot(false) end 
				if ImGui.MenuItem(" 删 除 ") then
					data_hander.delte_item(region.name, item.key)
					stack.snapshoot(true)
				end
				if ImGui.MenuItem(" 克 隆 ") then
					local new = data_hander.clone_item(region.name, item.key)
					if new then 
						data_hander.set_selected(region.name, new.key)
						stack.snapshoot(true)
					end
				end
				if ImGui.MenuItem(" 插 入 ") then 
					local key = data_hander.gen_next_item_name(region.name, "new item")
					if key and data_hander.add_item(region.name, key, i) then 
						data_hander.set_selected(region.name, key)
						stack.snapshoot(true)
					end
				end
				ImGui.EndPopup()
			end
			if ImGui.BeginDragDropSource() then 
				if data_hander.set_selected(region.name, item.key) then stack.snapshoot(false) end 
				imgui_utils.SetDragDropPayload("DrapIniItem", string.format("%s;%s", region.name, item.key));
				ImGui.Text("正在拖动 " .. item.key);
				ImGui.EndDragDropSource();
			end

			if imgui_utils.GetDragDropPayload("DrapIniItem") and ImGui.BeginDragDropTarget() then 
				local payload = imgui_utils.AcceptDragDropPayload("DrapIniItem")
				local arr = lib.split(payload, ";")
				local fromRegion = arr[1]
				local fromKey = arr[2]
				local error = data_hander.drag_item(fromRegion, fromKey, region.name, item.key)
				if error == true then 
					stack.snapshoot(true)
				elseif error then
					editor.msg_hints.show(error, "error")
				end
				ImGui.EndDragDropTarget()
			end

			ImGui.SameLineEx(30)
			ImGui.Text(item.key)
			ImGui.SameLineEx(160)
			ImGui.Text("=")
			ImGui.SameLineEx(200)
			ImGui.Text(item.value)
			if item.desc and item.desc ~= "" then
				ImGui.SameLineEx(len_x + 7)
				ImGui.TextColored(0, 0.8, 0, 1, item.desc or "")
			end
		end
		ImGui.EndGroup()
		--ImGui.Separator()
		ImGui.PopID()
		ImGui.Dummy(10, 15)
	end

	local function draw_menu()
		if ImGui.IsWindowHovered() and not ImGui.IsAnyItemHovered()  then 
			if ImGui.IsMouseReleased(ImGui.MouseButton.Right) then
				ImGui.OpenPopup("my_context_menu");
			elseif ImGui.IsMouseReleased(ImGui.MouseButton.Left) then 
				if data_hander.get_selected() then 
					data_hander.set_selected(nil)
				end
			end
		end
		
		if ImGui.BeginPopup("my_context_menu") then
			
            if ImGui.MenuItem("新建Region") then
				local region_name = data_hander.gen_next_region_name("new region")
				if data_hander.add_region(region_name) then
					data_hander.add_item(region_name, "new item")
					data_hander.set_selected(region_name)
					stack.snapshoot(true)
				else 
					editor.msg_hints.show(region_name .. " 已经存在", "error")
				end
			end
            ImGui.EndPopup()
        end
	end
	
	local function draw_detail(detail_x)
		local region = data_hander.get_selected_region()
		if not region then return end 

		local data_center = editor.data_center
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		local item = data_hander.get_selected_item()
		ImGui.SetCursorPos(5, 5)
		local header_len = math.min(100, detail_x * 0.4)
		local content_len = detail_x - header_len - 20
		ImGui.BeginGroup()
		if item then 
			local draw_data = {value = item.key, header = "名 字", header_len = header_len, content_len = content_len}
			if data_center.show_inspector("string", draw_data) then 
				if not data_hander.get_item(region.name, draw_data.new_value) then 
					item.key = draw_data.new_value
					data_hander.set_selected(region.name, item.key)
				end
				stack.snapshoot(true)
			end
			draw_data = {value = item.type, header = "类 型", header_len = header_len, content_len = content_len}
			if data_center.show_inspector("data_type", draw_data) then 
				item.type = draw_data.new_value
				stack.snapshoot(true)
			end
			draw_data = {value = item.value, header = "值", header_len = header_len, content_len = content_len}
			if data_center.show_inspector(item.type, draw_data) then 
				item.value = draw_data.new_value
				stack.snapshoot(true)
			end
			draw_data = {value = item.desc, header = "注 释", header_len = header_len, content_len = content_len}
			if data_center.show_inspector("string", draw_data) then 
				item.desc = draw_data.new_value
				stack.snapshoot(true)
			end
			
		elseif region then
			local draw_data = {value = region.name, header = "名 字", header_len = header_len, content_len = content_len}
			if data_center.show_inspector("string", draw_data) then 
				if not data_hander.get_region(draw_data.new_value) then
					region.name = draw_data.new_value
					data_hander.set_selected(region.name)
					stack.snapshoot(true)
				end
			end
			draw_data = {value = region.desc, header = "注 释", header_len = header_len, content_len = content_len}
			if data_center.show_inspector("string", draw_data) then 
				region.desc = draw_data.new_value
				stack.snapshoot(true)
			end
		end
		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	function api.set_data(data)
		data_hander.data = data or {}
		stack.set_data_handler(data_hander)
		stack.snapshoot(false)
	end 

	function api.update(delta_time)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local detail_x = math.min(300, size_x * 0.35)
		if size_x <= 20 then return end 
		
		content_x = data_hander.get_selected_region() and (size_x - detail_x) or size_x;
		if content_x <= 70 then content_x = size_x end

		ImGui.BeginChild("content", content_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.Dummy(10, 10)
		for i, region in ipairs(data_hander.data) do 
			draw_region(i, region)
		end
		draw_menu()
		ImGui.PopStyleVar()
		ImGui.EndChild()

		if content_x + detail_x == size_x then 
			ImGui.SetCursorPos(content_x, 0)
			ImGui.BeginChild("detail", detail_x, size_y, ImGui.ChildFlags({"Border"}))
			draw_detail(detail_x)
			ImGui.EndChild()
		end
	end

	return api
end

return {new = new}