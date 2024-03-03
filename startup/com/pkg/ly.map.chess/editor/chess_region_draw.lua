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
		api.draw_layers()
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

	function api.draw_layers()
		local draw_ground = function(x, y, pos)
			ImGui.SetCursorPos(pos.x, pos.y);
			imgui_utils.draw_btn("地面", false, {size_x = 95, size_y = 95})
		end

		for x = region.min.x, region.max.x do 
			for y = region.min.y, region.max.y do 
				draw_ground(x, y, {x = x * 100, y = y * 100})
			end
		end 
	end

	api.on_init()
	return api
end 


return {create = create}