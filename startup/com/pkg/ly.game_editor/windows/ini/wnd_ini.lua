--------------------------------------------------------
-- ini文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local uitls = require 'windows.utils'
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils
local imgui_styles = dep.common.imgui_styles

---@class ly.game_editor.ini.item
---@field type string	数据类型
---@field key string 数据key
---@field value string 数据值
---@field desc string 描述

---@class ly.game_editor.ini.region 
---@field name string region名字
---@field desc string 描述
---@field items ly.game_editor.ini.item[] 条目列表

local function new_data_handler()
	---@class ly.game_editor.ini.handler
	---@field data ly.game_editor.ini.region[]
	local api = {
		data = {}, 		
		stack_version = 0,
		isModify = false,
	}

	function api.has_item(region, key)
		return api.get_item(region, key) ~= nil
	end

	function api.has_region(region)
		return api.get_region(region) ~= nil
	end

	---@return ly.game_editor.ini.item
	function api.get_item(region, key)
		if not region or not key then return end
		local region = api.get_region(region) or {}
		for i, v in ipairs(region.items) do 
			if v.key == key then 
				return v
			end
		end
	end

	---@return ly.game_editor.ini.region
	function api.get_region(name)
		for i, v in ipairs(api.data) do 
			if v.name == name then 
				return v
			end
		end
	end

	---@return ly.game_editor.ini.region
	function api.add_region(name)
		if api.has_region(name) then return end 
		local region = {}
		region.name = name
		region.desc = ""
		region.items = {}
		table.insert(api.data, region)
		return region
	end

	---@return ly.game_editor.ini.item
	function api.add_item(region, key, index)
		if not key or api.has_item(region, key) then return end 

		local region = api.get_region(region)
		local data = {}
		data.key = key 
		data.value = ""
		data.type = ""
		if index then 
			table.insert(region.items, index, data)
		else 
			table.insert(region.items, data)
		end
		return data
	end

	---@return ly.game_editor.ini.item
	function api.clone_item(region_name, key)
		local region = api.get_region(region_name)
		if not region then return end 
		for i, item in ipairs(region.items) do 
			if item.key == key then 
				local new = dep.common.lib.copy(item)
				new.key = api.gen_next_item_name(region_name, item.key)
				table.insert(region.items, i + 1, new)	
				return new
			end
		end
	end

	function api.delte_region(region)
		for i, v in ipairs(api.data) do 
			if v.name == region then
				table.remove(api.data, i)
				return true
			end
		end
	end

	---@return ly.game_editor.ini.region
	function api.clone_region(region_name, index)
		local region = api.get_region(region_name)
		local new = dep.common.lib.copy(region)
		new.name = api.gen_next_region_name(region_name)
		table.insert(api.data, index, new);
		return new
	end

	function api.delte_item(region_name, key)
		local region = api.get_region(region_name)
		if not region then return end 
		for i, v in ipairs(region.items) do 
			if v.key == key then 
				table.remove(region.items, i)
				return true
			end
		end
	end

	function api.gen_next_region_name(region_name)
		local find = {}
		for i, v in ipairs(api.data) do 
			find[v.name] = true
		end

		if not find[region_name] then return region_name end 
		for i = 1, 9999 do 
			local name = region_name .. i
			if not find[name] then 
				return name
			end
		end
		return region_name
	end

	function api.gen_next_item_name(region_name, default_key)
		local region = api.get_region(region_name)
		if not region then return end 
		local find = {}
		for i, v in ipairs(region.items) do 
			find[v.key] = true
		end
		if not find[default_key] then return default_key end 
		for i = 1, 9999 do 
			local key = default_key .. i
			if not find[key] then 
				return key
			end
		end
		return default_key
	end

	function api.set_selected(region_name, key)
		local old_region, old_key = api.get_selected()
		if old_region == region_name and old_key == key then 
			return
		end
		local cache = api.data.cache or {}
		api.data.cache = cache
		cache.selected = {region = region_name, key = key}
		return true
	end

	function api.get_selected()
		local cache = api.data.cache
		if cache and cache.selected then 
			return cache.selected.region, cache.selected.key
		end
	end

	---@return ly.game_editor.ini.region
	function api.get_selected_region()
		local region_name = api.get_selected()
		return region_name and api.get_region(region_name)
	end

	---@return ly.game_editor.ini.item
	function api.get_selected_item()
		local region_name, key = api.get_selected()
		return api.get_item(region_name, key)
	end

	return api
end

---@param editor ly.game_editor.editor
local function create(editor)
	local api = {}
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = new_data_handler()
	api.data_hander = data_hander
	api.stack = stack

	local len_x = 350
	local content_x

	---@param region ly.game_editor.ini.region
	local function draw_region(index, region)
		ImGui.PushIDInt(index)
		ImGui.SetCursorPosX(math.max(10, (content_x - len_x) * 0.5))
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
			ImGui.SameLineEx(30)
			ImGui.Text(item.key)
			ImGui.SameLineEx(160)
			ImGui.Text("=")
			ImGui.SameLineEx(200)
			ImGui.Text(item.value)
		end
		ImGui.EndGroup()
		ImGui.PopID()
		ImGui.Dummy(10, 15)
	end

	local function draw_menu()
		if ImGui.IsWindowHovered() and ImGui.IsMouseReleased(ImGui.MouseButton.Right) and not ImGui.IsAnyItemHovered() then
            ImGui.OpenPopup("my_context_menu");
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
	
	local function draw_detail()
		local region = data_hander.get_selected_region()
		local item = data_hander.get_selected_item()
		if item then 
			ImGui.Text(string.format("item: %s - %s ", region.name, item.name))
			return
		end 

		if region then 
			ImGui.Text("region: " .. region.name)
		end
	end

	function api.set_data(data)
		data_hander.data = data or {}
		stack.set_data_handler(data_hander)
		stack.snapshoot(false)
	end 

	function api.update(delta_time)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local detail_x = 200
		if size_x <= 20 then return end 

		content_x = size_x - 200;
		if content_x <= 50 then content_x = size_x end
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
			draw_detail()
			ImGui.EndChild()
		end
	end

	return api
end

---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 			---@class ly.game_editor.wnd_ini
	local main = create(editor)

	function api.update(delta_time)
		main.update(delta_time)
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return main.data_hander.isModify
	end

	function api.handleKeyEvent()
		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
			if ImGui.IsKeyPressed(ImGui.Key.Z, false) then main.stack.undo() end
			if ImGui.IsKeyPressed(ImGui.Key.Y, false) then main.stack.redo() end
		end
	end

	function api.reload()
		main.set_data(uitls.load_file(full_path))
	end

	function api.close()
	end 

	function api.save()
		uitls.save_file(full_path, main.data_hander)
	end 

	api.reload()
	return api 
end


return {new = new}