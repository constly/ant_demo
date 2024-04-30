local dep = require 'dep' ---@type ly.game_editor.dep
local ImGui = dep.ImGui
local ed = dep.ed
local imgui_utils = dep.common.imgui_utils
local ImGuiExtend = dep.ImGuiExtend
local draw_list = ImGuiExtend.draw_list;
local tb_drag_data = {}

---@param editor ly.game_editor.editor
---@param renderer ly.map.renderer
---@return ly.game_editor.draw_map
local function new(editor, renderer)
	---@class ly.game_editor.draw_map
	local api = {}
	local region 	---@type chess_map_region_tpl
	local context
	local needNavigateTo
	local is_dragging = false
	local drag_start_point
	local data_hander = renderer.data_hander

	function api.on_init()
		if not context then 
			context = ed.CreateCanvasContext()
		end
		needNavigateTo = true;
	end

	function api.on_destroy()
		if context then 
			context = nil
		end
	end

	function api.on_render(deltatime)
		region = data_hander.cur_region()
		api.process_scale()
		if context:Begin("chess_canvas", 0, 0) then
			api.process_drag()
			api.draw_selected()
			api.draw_grounds()
			api.draw_layers()
			if needNavigateTo or ImGui.IsKeyPressed(ImGui.Key.Space, false) then 
				api.NavigateToContent(); 
				needNavigateTo = false 
			end
			context:End()
		end
	end

	function api.process_scale()
		if not ImGui.IsWindowHovered() then return end
		local io = ImGui.GetIO()
		if io.MouseWheel ~= 0 then 
			local viewScale = context:ViewScale();
			local mousePos = io.MousePos
			local local_x, local_y = context:ToLocal(mousePos.x, mousePos.y)
			local scale = viewScale + (io.MouseWheel > 0 and 0.125 or -0.125)
			scale = scale < 0.1 and 0.1 or scale
			if scale ~= viewScale then 
				local origin_x, origin_y = context:ViewOrigin()
				origin_x = origin_x - local_x * (scale - viewScale)
				origin_y = origin_y - local_y * (scale - viewScale)
				context:SetView(origin_x, origin_y, scale)
			end
			
		end
	end

	function api.process_drag()
		if (is_dragging or ImGui.IsItemHovered()) and ImGui.IsMouseDragging(1, 0) then 
			if (not is_dragging) then
				is_dragging = true
				local x, y = context:ViewOrigin()
				drag_start_point = {x = x, y = y}
			end
			local scale = context:ViewScale()
			local delta_x, delta_y = ImGui.GetMouseDragDelta(1, 0)
			delta_x, delta_y = delta_x * scale, delta_y * scale
			local targetView = {x = drag_start_point.x + delta_x, y = drag_start_point.y + delta_y}
			context:SetView(targetView.x, targetView.y, scale)
		elseif is_dragging then 
			is_dragging = false
		end
	end

	function api.NavigateToContent()
		local min_x = region.min.x * 100
		local min_y = region.min.y * 100
		local max_x = (region.max.x + 1) * 100 
		local max_y = (region.max.y + 1) * 100
		local size_x, size_y = ImGui.GetWindowSize()
		local scale = 0.5
		local offset_x = (min_x + max_x) * -0.5 * scale + size_x * 0.5 
		local offset_y = (min_y + max_y) * -0.5 * scale + size_y * 0.5
		context:SetView(offset_x, offset_y, scale)
	end

	function api.draw_grounds()
		if not data_hander.data.show_ground then return end
		local bg_color = {0.15, 0.15, 0.15, 0.3}
		local txt_color = {0.8, 0.8, 0.8, 0.8}
		local draw_ground = function(x, y, pos)
			ImGui.SetCursorPos(pos.x + 2.5, pos.y + 2.5);
			local label = string.format("(%d,%d)##btn_g_%d_%d", x, y, x, y)
			ImGui.SetNextItemAllowOverlap();
			if imgui_utils.draw_color_btn(label, bg_color, txt_color, {size_x = 95, size_y = 95}) then 
				api.notify_click_ground(x, y)
			end

			if ImGui.BeginDragDropTarget() then 
				local payload = ImGui.AcceptDragDropPayload("PutObject")
            	if payload then
					local objId = tonumber(payload)
					if objId then 
						if data_hander.is_multi_selected(region) then
							renderer.put_object_to_selected(objId)
						else
							if api.notify_drop_object_to_grid(objId, x, y) then 
								renderer.stack.snapshoot(true)
							end
						end
					end
				end

				payload = ImGui.AcceptDragDropPayload("DragObject")
				if payload then
					local layerId, gridId, pos_x, pos_y = table.unpack(tb_drag_data)
					if data_hander.is_multi_selected(region) then 
						local offset_x, offset_y = x - pos_x, y - pos_y
						if data_hander.drag_selected_object(region, offset_x, offset_y) then 
							renderer.stack.snapshoot(true)
						end
					else
						local layer = data_hander.get_layer_by_id(region, layerId)
						local newGridId = data_hander.grid_pos_to_grid_id(x, y)
						if gridId and layer and newGridId ~= gridId then 
							layer.grids[gridId], layer.grids[newGridId] = layer.grids[newGridId], layer.grids[gridId]
							renderer.stack.snapshoot(true)
						end
					end
				end
				ImGui.EndDragDropTarget()
			end
		end

		for x = region.min.x, region.max.x do 
			for y = region.min.y, region.max.y do 
				draw_ground(x, y, {x = x * 100, y = y * 100})
			end
		end 

		local draw_btns = function(center, dir)
			local p1, p2, p3, p4 
			if dir == "up" or dir == "down" then 
				p1 = {x = center.x - 30, y = center.y}
				p2 = {x = center.x + 30, y = center.y}
				p3 = {x = center.x - 90, y = center.y}
				p4 = {x = center.x + 90, y = center.y}
			else 
				p1 = {x = center.x, y = center.y - 30}
				p2 = {x = center.x, y = center.y + 30}
				p3 = {x = center.x, y = center.y - 90}
				p4 = {x = center.x, y = center.y + 90}
			end
			local flag = 0;
			ImGui.SetCursorPos(p1.x, p1.y)
			if imgui_utils.draw_btn("+1##region_add1" .. dir, false, {size_x = 50, size_y = 50}) then flag = 1 end

			ImGui.SetCursorPos(p2.x, p2.y)
			if imgui_utils.draw_btn("-1##region_rem1" .. dir, false, {size_x = 50, size_y = 50}) then flag = -1 end

			ImGui.SetCursorPos(p3.x, p3.y)
			if imgui_utils.draw_btn("+5##region_add2" .. dir, false, {size_x = 50, size_y = 50}) then flag = 5 end

			ImGui.SetCursorPos(p4.x, p4.y)
			if imgui_utils.draw_btn("-5##region_rem2" .. dir, false, {size_x = 50, size_y = 50}) then flag = -5 end

			if flag ~= 0 then 
				if dir == "up" then region.min.y = math.min(10000, math.max(-10000, math.min(region.max.y, region.min.y - flag)))
				elseif dir == "down" then region.max.y = math.min(10000, math.max(-10000, math.max(region.min.y, region.max.y + flag)))
				elseif dir == "left" then region.min.x = math.min(10000, math.max(-10000, math.min(region.max.x, region.min.x - flag)))
				elseif dir == "right" then region.max.x = math.min(10000, math.max(-10000, math.max(region.min.x, region.max.x + flag)))
				end
				renderer.stack.snapshoot(true)
			end
		end
		local start_x, start_y, end_x, end_y = region.min.x, region.min.y, region.max.x, region.max.y
		draw_btns({x = start_x * 100 - 75, y = (start_y + end_y) * 0.5 * 100 + 20}, "left")
		draw_btns({x = (end_x + 1) * 100 + 25, y = (start_y + end_y) * 0.5 * 100 + 20}, "right")
		draw_btns({x = (start_x + end_x) * 0.5 * 100 + 25, y = start_y * 100 - 75}, "up")
		draw_btns({x = (start_x + end_x) * 0.5 * 100 + 25, y = (end_y + 1) * 100 + 25}, "down")
	end

	function api.draw_layers()
		local isDraging = ImGui.IsMouseDragging(0) and renderer.is_window_active
		local draw_object = function(layerId, gridId, text, bg_color, txt_color, size, uid)
			local label = string.format("%s##btn_grid_%d_%s", text, layerId, gridId)
			local size_x = size.x * 100
			local size_y = size.y * 100
			local pos_x, pos_y = data_hander.grid_id_to_grid_pos(gridId)
			ImGui.SetNextItemAllowOverlap();
			ImGui.SetCursorPos(pos_x * 100 + 2.5, pos_y * 100 + 2.5);
			if isDraging then 
				bg_color = {table.unpack(bg_color)}; bg_color[4] = bg_color[4] * 0.5
				txt_color = {table.unpack(txt_color)}; txt_color[4] = txt_color[4] * 0.1
			end
			if imgui_utils.draw_color_btn(label, bg_color, txt_color, {size_x = size_x - 5, size_y = size_y - 5}) then 
				api.notify_click_object(layerId, uid, {pos_x, pos_y})
			end

			if ImGui.BeginDragDropSource() then 
				if not data_hander.has_selected(region, "object", uid, layerId, {pos_x, pos_y}) then 
					api.notify_click_object(layerId, uid, {pos_x, pos_y})
				end
				tb_drag_data = {layerId, gridId, pos_x, pos_y}
				ImGui.SetDragDropPayload("DragObject", string.format("%s,%s", layerId, gridId));
				ImGui.EndDragDropSource();
			end
		end 

		for _, layer in ipairs(region.layers) do 
			if layer.active then 
				for gridId, grid in pairs(layer.grids) do 
					if not data_hander.is_invisible(region, grid.id) then
						local tpl = data_hander.get_object_tpl(grid.tpl) 
						if tpl then 
							draw_object(layer.id, gridId, tpl.name, tpl.bg_color, tpl.txt_color, tpl.size, grid.id)
						else 
							draw_object(layer.id, gridId, "ID:" .. grid.tpl .. "丢失", {1, 0, 0, 1}, {1, 1, 1, 1}, {x = 3, y = 3}, 0)
						end
					end
				end
			end
		end
	end

	-- 显示选中的格子/物件
	function api.draw_selected()
		local draw = function(x, y, size)
			local pos_x, pos_y = x * 100, y * 100
			ImGui.SetCursorPos(pos_x, pos_y);
			local bg_color = {0, 0.75, 0, 1.0}
			local p1, p2 = ImGui.GetCursorScreenPos()
			draw_list.AddRectFilled({min = {p1, p2}, max = {p1 + size.x * 100, p2 + size.y * 100}, col = bg_color});      
		end

		local cache = data_hander.data.cache
		local list = cache.selects[region.id] or {}
		if cache.shift and #list == 2 then 
			local x1, y1, x2, y2 = data_hander.get_shift_selected_range(region)
			draw(x1, y1, {x = x2 - x1 + 1, y = y2 - y1 + 1})

		else
			for i, v in ipairs(list) do 
				if v.type == "ground" then 
					local x, y = data_hander.grid_id_to_grid_pos(v.id)
					draw(x, y, {x = 1, y = 1})

				elseif v.type == "object" then
					local layer = data_hander.get_layer_by_id(region, v.layer)
					if layer and layer.active then 
						local data, gridId = data_hander.get_grid_data_by_uid(region, v.layer, v.id)
						if data then 
							local x, y = data_hander.grid_id_to_grid_pos(gridId)
							local tpl = data_hander.get_object_tpl(data.tpl)
							if tpl then 
								draw(x, y, tpl.size)
							end
						end
					end
				end
			end
		end
	end

	-- 点击地面格子
	function api.notify_click_ground(x, y)
		local id = data_hander.grid_pos_to_grid_id(x, y)
		local ok = true
		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
			ok = data_hander.add_selected(region, "ground", id, nil, {x, y})
		elseif ImGui.IsKeyDown(ImGui.Key.LeftShift) then 
			ok = data_hander.add_selected_shift(region, "ground", id, nil, {x, y})
		else
			data_hander.clear_selected(region)
			ok = data_hander.add_selected(region, "ground", id, nil, {x, y})
		end
		if ok then 
			renderer.stack.snapshoot(false)
		end
	end

	-- 点击物件
	function api.notify_click_object(layerId, uid, pos)
		local ok = true
		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) and pos then 
			ok = data_hander.add_selected(region, "object", uid, layerId, pos)
		elseif ImGui.IsKeyDown(ImGui.Key.LeftShift) and pos then 
			ok = data_hander.add_selected_shift(region, "object", uid, layerId, pos)
		else 
			data_hander.clear_selected(region)
			ok = data_hander.add_selected(region, "object", uid, layerId, pos)
		end 
		if ok then 
			renderer.stack.snapshoot(false)
		end
	end

	-- 拖动物件到格子
	function api.notify_drop_object_to_grid(objId, x, y)
		local top = data_hander.get_top_active_layer(region)
		if top then 
			local gridId = data_hander.grid_pos_to_grid_id(x, y)
			local data = top.grids[gridId]
			if not data or data.tpl ~= objId then 
				top.grids[gridId] = data_hander.create_grid_tpl(objId)
				return true;
			end
		end
	end

	api.on_init()
	return api
end 

return {new = new}