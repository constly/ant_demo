--------------------------------------------------------
-- style 窗口渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.style.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.style.renderer
	local api = {}
	local len_x = 380
	local content_x

	---@type ly.game_editor.style.all[] 
	local all_styles = require 'editor.style'.get_styles()
	local all_attr = require 'editor.style'.get_attrs()
	local cache_name2type = {}

	---@param item ly.game_editor.style.all_item 
	local function draw_type_hint(item)
		local style = data_hander.get_style(item.name)
		if not style then return end 

		local tb_attrs = all_attr[item.type]
		if not tb_attrs or #tb_attrs == 0 then return end 

		ImGui.SameLineEx(len_x + 20)
		local values = style.values
		for i, attr in ipairs(tb_attrs) do 
			local type, name, tip, enum, default = table.unpack(attr)
			local v = values[name]
			if v then
				if type == "col" or type == "cell_bg" then 
					local label = string.format("##btn_style_preview_%s_%d", item.name, i)
					ImGui.SetNextItemWidth(40)
					if ImGui.ColorEdit4(label, v, ImGui.ColorEditFlags { "NoInputs" }) then 
						stack.snapshoot(true)
					end
				elseif type == "style_var" then 
					ImGui.Text(string.format("{%s,%s}", v[1] or 0, v[2] or 0))
				else 
					ImGui.Text("unknown:" .. type)
				end
				ImGui.SameLine()
			end
		end
		ImGui.NewLine()
	end

	local function draw_body()
		local current = data_hander.get_selected()
		ImGui.SetCursorPos(10, 5)
		ImGui.BeginGroup()
		for i, category in ipairs(all_styles) do 
			local len = ImGui.CalcTextSize(category.name)
			ImGui.SameLineEx((len_x - len) * 0.5 - 10)
			ImGui.Text(category.name)	
			for j, item in ipairs(category.list) do 
				local _style = (current == item.name) and GStyle.btn_normal_selected or GStyle.btn_normal
				local label = string.format("##btn_style_%d_%d", i, j)
				if editor.style.draw_style_btn(label, _style, {size_x = len_x}) then 
					if data_hander.set_selected(item.name) then stack.snapshoot(false) end
				end
				if ImGui.BeginPopupContextItem() then 
					if data_hander.set_selected(item.name) then stack.snapshoot(false) end 
					if ImGui.MenuItem("重 置") then
						data_hander.reset_style(item.name)
						stack.snapshoot(true)
					end
					ImGui.EndPopup()
				end
				ImGui.SameLineEx(10)
				ImGui.Text(item.desc)
				ImGui.SameLineEx(150)
				ImGui.Text(":")
				ImGui.SameLineEx(160)
				ImGui.Text(item.name)

				draw_type_hint(item)
			end 
			ImGui.NewLine()
			ImGui.NewLine()
		end 
		ImGui.EndGroup()
	end

	local function draw_menu()
		if ImGui.IsWindowHovered() and not ImGui.IsAnyItemHovered()  then 
			if ImGui.IsMouseReleased(ImGui.MouseButton.Right) then
				ImGui.OpenPopup("my_context_menu");
			elseif ImGui.IsMouseReleased(ImGui.MouseButton.Left) then 
				data_hander.set_selected()
			end
		end
		if ImGui.BeginPopup("my_context_menu") then
			data_hander.set_selected()
            if ImGui.MenuItem("重置所有样式到默认值") then
				data_hander.reset_all_styles()
				stack.snapshoot(true)
			end
            ImGui.EndPopup()
        end
	end

	local function draw_detail(detail_x)
		local style_name = data_hander.get_selected()
		local style = data_hander.get_style(style_name)
		if not style then return end 

		local style_type = cache_name2type[style_name]
		if not style_type then return end 

		local data_center = editor.data_center
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.SetCursorPos(5, 5)
		local header_len = math.min(100, detail_x * 0.4)
		local content_len = detail_x - header_len - 20
		ImGui.BeginGroup()

		local values = style.values
		local tb_attrs = all_attr[style_type]
		local draw_data = {header_len = header_len, content_len = content_len, is_table = true}
		for i, attr in ipairs(tb_attrs) do 
			local type, name, tip, enum, default = table.unpack(attr)
			local v = values[name]
			if v then 
				if type == "col" or type == "cell_bg" then 
					draw_data.header = tip
					draw_data.value = values[name]
					if data_center.show_inspector("color", draw_data) then 
						values[name] = draw_data.new_value
						stack.snapshoot(true)
					end
				elseif type == "style_var" then 
					draw_data.header = tip
					draw_data.value = values[name]
					draw_data.precision = 2
					if data_center.show_inspector("vec2", draw_data) then 
						values[name] = draw_data.new_value
						stack.snapshoot(true)
					end
				end
			end
		end

		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	function api.set_data(data)
		data_hander.init(all_styles, all_attr, data)
		stack.set_data_handler(data_hander)
		stack.snapshoot(false)

		cache_name2type = {}
		for i, category in ipairs(all_styles) do 
			for _, item in ipairs(category.list) do 
				cache_name2type[item.name] = item.type	
			end
		end
	end

	function api.update(delta_time)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local detail_x = math.min(300, size_x * 0.35)
		if size_x <= 20 then return end 

		content_x = data_hander.get_selected() and (size_x - detail_x) or size_x;
		if content_x <= 70 then content_x = size_x end
		ImGui.BeginChild("content", content_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		draw_body()
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