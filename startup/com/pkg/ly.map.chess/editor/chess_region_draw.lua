local dep = require 'dep' ---@type ly.map.chess.dep
local ImGui = dep.ImGui
local ed = dep.ed
local imgui_utils = dep.common.imgui_utils

---@param editor chess_editor
---@return chess_region_draw
local create = function(editor)
	---@class chess_region_draw
	local api = {}
	local region 	---@type chess_map_region_tpl
	local context
	local needNavigateTo
	local is_dragging = false
	local drag_start_point

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
		region = editor.data_hander.cur_region()
		api.process_scale()
		context:Begin("chess_canvas", 0, 0)
		api.process_drag()
		api.draw_grounds()

		if needNavigateTo or ImGui.IsKeyPressed(ImGui.Key.Space, false) then api.NavigateToContent(); needNavigateTo = false end
		context:End()
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
		local max_x = (region.max.x - 1) * 100 
		local max_y = (region.max.y - 1) * 100
		local size_x, size_y = ImGui.GetWindowSize()
		context:SetView((min_x + max_x) * 0.5 + size_x * 0.5, (min_y + max_y) * 0.5 + size_y * 0.5, 0.5)
	end

	function api.draw_grounds()
		local bg_color = {0.15, 0.15, 0.15, 0.3}
		local txt_color = {0.8, 0.8, 0.8, 0.8}
		local draw_ground = function(x, y, pos)
			ImGui.SetCursorPos(pos.x, pos.y);
			local label = string.format("(%d,%d)##btn_g_%d_%d", x, y, x, y)
			imgui_utils.draw_color_btn(label, bg_color, txt_color, {size_x = 95, size_y = 95})

			if ImGui.BeginDragDropTarget() then 
				local payload = ImGui.AcceptDragDropPayload("DragObject")
            	if payload then
					local idx = tonumber(payload)
					if idx then 
						print("idx is", idx)
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
				if dir == "up" then region.min.y = math.max(-10000, math.min(region.max.y, region.min.y - flag))
				elseif dir == "down" then region.max.y = math.max(-10000, math.max(region.min.y, region.max.y + flag))
				elseif dir == "left" then region.min.x = math.max(-10000, math.min(region.max.x, region.min.x - flag))
				elseif dir == "right" then region.max.x = math.max(-10000, math.max(region.min.x, region.max.x + flag))
				end
				editor.stack.snapshoot(true)
			end
		end
		local start_x, start_y, end_x, end_y = region.min.x, region.min.y, region.max.x, region.max.y
		draw_btns({x = start_x * 100 - 75, y = (start_y + end_y) * 0.5 * 100 + 20}, "left")
		draw_btns({x = (end_x + 1) * 100 + 25, y = (start_y + end_y) * 0.5 * 100 + 20}, "right")
		draw_btns({x = (start_x + end_x) * 0.5 * 100 + 25, y = start_y * 100 - 75}, "up")
		draw_btns({x = (start_x + end_x) * 0.5 * 100 + 25, y = (end_y + 1) * 100 + 25}, "down")
	end


	api.on_init()
	return api
end 


return {create = create}