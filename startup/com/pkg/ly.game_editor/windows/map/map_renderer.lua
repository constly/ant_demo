local dep = require "dep" ---@type ly.game_editor.dep
local ImGui = dep.ImGui
local lib = dep.common.lib

---@type ly.game_core
local game_core = import_package 'ly.game_core'

---@param editor ly.game_editor.editor
---@param args chess_editor_create_args
---@param wnd ly.game_editor.wnd_map
local function new(editor, args, wnd)
	---@class ly.map.renderer
	local api = {}	
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = game_core.create_map_handler()  ---@type chess_data_handler
	api.data_hander = data_hander
	api.stack = stack
	api.args = args
	api.tb_object_def = args.tb_objects					---@type chess_object_tpl[]
	api.is_window_active = true
		
	local draw_main = require 'windows.map.draw_main'.create(editor, api, wnd)				---@type ly.game_editor.draw_main

	function api.on_init()
		stack.set_data_handler(data_hander)	
		data_hander.init(lib.copy(args.data))
		api.refresh_object_def()
		stack.snapshoot()
	end

	function api.on_destroy()
		draw_main.on_destroy()
	end

	function api.on_reset()
		local _args = lib.copy(args)  		---@type chess_editor_create_args
		_args.data = nil
		local setting = data_hander.data.setting
		data_hander.init(_args)
		data_hander.data.setting = setting or {}
		api.refresh_object_def()
		stack.snapshoot(true)
	end

	function api.on_save(write_callback)
		local cache = data_hander.data.cache
		data_hander.data.cache = nil
		local content = dep.serialize.stringify(data_hander.data)
		data_hander.data.cache = cache
		data_hander.isModify = false
		write_callback(content)
	end

	---@param is_active boolean 窗口是否激活
	---@param delta_time number 更新间隔，秒
	function api.on_render(is_active, delta_time)
		api.is_window_active = is_active
		draw_main.on_render(delta_time)
	end 

	function api.handleKeyEvent()
		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
			if ImGui.IsKeyPressed(ImGui.Key.Z, false) then stack.undo() end
			if ImGui.IsKeyPressed(ImGui.Key.Y, false) then stack.redo() end
		end
		if ImGui.IsKeyPressed(ImGui.Key.Delete, false) then 
			local region = data_hander.cur_region()
			if data_hander.delete_all_selected(region) then
				stack.snapshoot(true)
			end
		end	
		if ImGui.IsKeyPressed(ImGui.Key.P, false) then 
			local region = data_hander.cur_region()
			local object_id = data_hander.data.cur_object_id
			if region and object_id then
				local dirty = false
				if data_hander.is_multi_selected(region) and data_hander.is_shift_selected(region)  then 
					local x1, y1, x2, y2 = data_hander.get_shift_selected_range(region)
					local tpl = data_hander.get_object_tpl(object_id)
					if tpl then
						local layer = data_hander.get_top_active_layer(region)
						for x = x1, x2 do 
							for y = y1, y2 do 
								local gridId = data_hander.grid_pos_to_grid_id(x, y)
								if layer then 
									layer.grids[gridId] = nil
								end
							end
						end
						
						for x = x1, x2, tpl.size.x do 
							for y = y1, y2, tpl.size.y do 
								if (x + tpl.size.x - 1 <= x2) and (y + tpl.size.y - 1 <= y2) then
									dirty = draw_main.draw_map.notify_drop_object_to_grid(object_id, x, y)
								end
							end
						end
					end

				else 
					local list = data_hander.data.cache.selects[region.id] or {}
					for i, v in ipairs(list) do 
						local t, id, layerId = v.type, v.id, v.layer
						if id then 
							if t == "ground" then
								local x, y = data_hander.grid_id_to_grid_pos(id)
								dirty = draw_main.draw_map.notify_drop_object_to_grid(object_id, x, y)
							elseif t == "object"  then
								local gridData, gridId = data_hander.get_grid_data_by_uid(region, layerId, id)
								if gridData then 
									local x, y = data_hander.grid_id_to_grid_pos(gridId)
									dirty = draw_main.draw_map.notify_drop_object_to_grid(object_id, x, y)
								end
							end
						end
					end
				end
				if dirty then 
					stack.snapshoot(true)
				end
			end
		end
	end

	function api.is_dirty()
		return data_hander.isModify;
	end

	function api.refresh_object_def()
		if data_hander.has_path_def() then 
			local tbFile = dep.common.file.load_csv(data_hander.data.setting.grid_def)
			--dep.common.lib.dump(tbFile)
			local list = {}
			for i, v in ipairs(tbFile) do 
				local data = {}
				data.id = tonumber(v.id) or 0
				if data.id > 0 then
					data.name = v.name or ""
					data.size = lib.string_to_vec2(v.size)
					data.bg_color = lib.eval(v.bg_color) or {0, 0, 0, 1}
					data.txt_color = lib.eval(v.txt_color) or {0.9, 0.9, 0.9, 1}
					table.insert(list, data)
				end
			end
			api.tb_object_def = list
		end
		data_hander.refresh_path_def(api.tb_object_def)
	end
	
	api.on_init()
	return api
end 

return {new = new}