-----------------------------------------------------------------------
--- 创建房间
-----------------------------------------------------------------------

---@class sims.client.create_room.scene 
---@field key string 场景文件夹
---@field path string 场景路径
---@field name string 名字
---@field tip string 描述

---@param s sims.client.state_machine
---@param client sims.client
local function new(s, client)
	local ImGui 		= require "imgui"
	---@type ly.common
	local common 		= import_package 'ly.common' 	
	local lib 			= common.lib

	---@type sims.client.create_room.scene[]
	local scenes = {}

	---@type sims.client.state_machine.state_base 
	local api = {} 

	local cur_idx = 1

	function api.on_entry()
		scenes = api.get_scenes()
	end

	function api.on_update()
		local viewport = ImGui.GetMainViewport();
		local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
		local width, height = 400, 40 * #scenes + 200
		local top_x, top_y = (size_x - width) * 0.5, (size_y - height) * 0.5 - 50
		ImGui.SetNextWindowPos(top_x, top_y)
		ImGui.SetNextWindowSize(width, height);

		local window_flag = ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse"}
		local ret, open = ImGui.Begin("##window_body", true, window_flag) 
		if ret then 
			ImGui.Dummy(20, 5)
			common.imgui_utils.draw_text_center("创建局域网房间")
			ImGui.SetCursorPos(60, 90)
			ImGui.BeginGroup()

			local pos_x, pos_y = ImGui.GetCursorPos()
			local y = pos_y
			for i, data in ipairs(scenes) do 
				local key = string.format("##btn_room_%d", i) 
				ImGui.SetCursorPos(pos_x, y)
				if common.imgui_utils.draw_btn(key, cur_idx == i, {size_x = 280, size_y = 32}) then 
					cur_idx = i
				end
				if data.tip and ImGui.BeginItemTooltip() then 
					ImGui.Text(data.tip)
					ImGui.EndTooltip()
				end

				y = y + 3
				ImGui.SetCursorPos(pos_x + 10, y)
				ImGui.Text(string.format("%d.", i))

				ImGui.SetCursorPos(pos_x + 30, y)
				ImGui.Text(string.format("%s", data.key))
				
				ImGui.SetCursorPos(pos_x + 120, y)
				ImGui.Text(string.format("%s", data.name))
				y = y + 32
			end
			ImGui.EndGroup()
			ImGui.SetCursorPos(130, height - 80)
			if common.imgui_utils.draw_btn("确 定", scenes[cur_idx] ~= nil, {size_x = 120, size_y = 28}) then 
				local scene = scenes[cur_idx]
				if scene then 
					local path = string.format("%s/%s.txt", scene.path, scene.key)
					client.create_room(path, scene)
				end
			end
			ImGui.End()
		end
		
		if not open then
			s.goto_state(s.state_entry)
		end
	end

	function api.on_exit()
	end

	function api.get_scenes()
		local list = {}
		---@type ly.game_core
		local game_core = import_package 'ly.game_core'
		local package_handler = game_core.create_package_handler(common.path_def.project_root)
		local handler = game_core.create_ini_handler()
		local files = package_handler.get_all_files("mod.main", "scenes")
		for _, file in ipairs(files) do 
			if lib.end_with(file, "desc.ini") then 
				local path = lib.get_file_root(file)
				local name = lib.get_file_name(path)
				handler.load_by_path(file);

				---@type sims.client.create_room.scene
				local data = {}
				data.key = name
				data.path = path
				data.name = handler.get_value("global", "name")
				data.tip = handler.get_value("global", "tip")
				
				table.insert(list, data)
			end
		end
		return list
	end

	return api
end

return {new = new}