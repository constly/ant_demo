--------------------------------------------------------
-- attr 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.attr.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.attr.renderer
	local api = {}

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
			ImGui.SameLineEx(10)
			ImGui.Text(string.format("%s : %s", v.type, v.id))
			ImGui.SameLineEx(200)
			ImGui.Text(v.name or "")
			ImGui.SameLineEx(360)
			ImGui.Text(v.desc or "")
		end
		if editor.style.draw_btn(" + ##btn_add", false, {size_x = 60}) then 
			local name = data_hander.next_attr_id(region.id, "attr")
			data_hander.add_item(region.id, name)
			stack.snapshoot(true)
		end
		ImGui.EndGroup()
	end

	local function draw_detail(detail_x)
		local region = data_hander.get_selected_region()
		if not region then return end 
		local attr = data_hander.get_attr(region.id, data_hander.get_selected_attr_id(region.id))
		if not attr then return end 

		local data_center = editor.data_center
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()

		local header_len = math.min(100, detail_x * 0.4)
		local content_len = detail_x - header_len - 20

		local draw_data = {value = attr.id, header = "变量名(ID)", header_len = header_len, content_len = content_len}
		if data_center.show_inspector("string", draw_data) then 
			if not data_hander.get_attr(region.id, draw_data.new_value) then 
				attr.id = draw_data.new_value
				data_hander.set_selected_attr(region.id, attr.id)
				stack.snapshoot(true)
			else 
				editor.msg_hints.show(string.format("变量名:%s 已经存在", draw_data.new_value), "error")
			end
		end

		draw_data = {value = attr.type, header = "变量类型", header_len = header_len, content_len = content_len}
		if data_center.show_inspector("data_type", draw_data) then 
			attr.type = draw_data.new_value
			stack.snapshoot(true)
		end

		draw_data = {value = attr.name, header = "中文名字", header_len = header_len, content_len = content_len}
		if data_center.show_inspector("string", draw_data) then 
			attr.name = draw_data.new_value
			stack.snapshoot(true)
		end

		draw_data = {value = attr.desc, header = "变量说明", header_len = header_len, content_len = content_len}
		if data_center.show_inspector("string", draw_data) then 
			attr.desc = draw_data.new_value
			stack.snapshoot(true)
		end

		-- draw_data = {value = attr.category, header = "变量分类", header_len = header_len, content_len = content_len}
		-- if data_center.show_inspector("string", draw_data) then 
		-- 	attr.category = draw_data.new_value
		-- 	stack.snapshoot(true)
		-- end

		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	function api.update()
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.SetCursorPos(6, 5)
		ImGui.BeginGroup()
		for i, v in ipairs(data_hander.data.regions) do 
			local label = string.format("%s##btn_region_%d", v.id, i)
			local is_selected = data_hander.get_selected_region_id() == v.id
			if editor.style.draw_btn(label, is_selected) then 
				data_hander.set_selected_region(v.id)
			end 
			ImGui.SameLine()
		end 
		if editor.style.draw_btn("  +  ##btn_region_add") then 
			local region = data_hander.add_region(data_hander.next_region_id("region"))
			data_hander.set_selected_region(region.id)
			stack.snapshoot(true)
		end
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