local ecs = ...
local ImGui  = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_10_system",
    category        = mgr.type_imgui,
    name            = "10_节点编辑器",
    file            = "imgui/imgui_10.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local ImGuiExtend = require "imgui.extend"
local draw_list = ImGuiExtend.draw_list
local blueprint = ImGuiExtend.blueprint
local scrolling = {x = 0.0, y = 0.0};
local is_dragged = false
local scale = 1
local node_width = 100
local node_height = 300
local region_x, region_y
local is_canvas_hovered
local cur_node = -1
local nodes = {
	{id = 1, order = 1, pos = {x = 120, y = 60}},
	{id = 2, order = 1, pos = {x = 580, y = 60}},
	{id = 3, order = 1, pos = {x = 320, y = 300}},
}
local max_node_id = #nodes + 1

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		local size_x, size_y = ImGui.GetContentRegionAvail();
		local left = 250
		ImGui.Text("开发中...")

		ImGui.SetCursorPos(10, 100)
		if ImGui.ButtonEx("重置视图", 80) then 
			system.reset_view()
		end

		ImGui.SetCursorPos(left, 10)
		region_x = size_x - left
		region_y = size_y
		ImGui.BeginChild("##child_1", region_x, region_y, ImGui.ChildFlags{"None"}, ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"})
			ImGui.SetWindowFontScale(scale);
			system.draw_background();
			system.draw_nodes()
			system.process_mouse_event()
			ImGui.SetWindowFontScale(1);
		ImGui.EndChild()
	end 
	ImGui.End()
end

function system.draw_background()
	local min_x, min_y = ImGui.GetCursorScreenPos();      -- ImDrawList API uses screen coordinates!
	local size_x, size_y = ImGui.GetContentRegionAvail();
	local max_x, max_y = min_x + size_x, min_y + size_y;   

	draw_list.AddRectFilled({min = {min_x, min_y}, max = {max_x, max_y}, col = {0.25, 0.25, 0.25, 1}});
	draw_list.AddRect({min = {min_x, min_y}, max = {max_x, max_y}, col = {1, 1, 1, 1}});

	ImGui.InvisibleButton("canvas", size_x, size_y, ImGui.ButtonFlags{ "MouseButtonLeft", "MouseButtonRight"} );
	is_canvas_hovered = ImGui.IsItemHovered(); 

	if not is_dragged and ImGui.IsMouseReleased(ImGui.MouseButton.Right)then
		ImGui.OpenPopupOnItemClick("context", ImGui.PopupFlags{"MouseButtonRight"});
	end

	local wndx, wndy = ImGui.GetWindowPos()
	if ImGui.BeginPopup("context") then 
		if ImGui.MenuItem("新 增") then 
			local popx, popy = ImGui.GetWindowPos()
			local x, y = (popx - wndx - scrolling.x) / scale, (popy - wndy - scrolling.y) / scale
			table.insert(nodes, {
				id = max_node_id,
				order = os.clock(),
				pos = {x = x, y = y}
			})
			max_node_id = max_node_id + 1
			system.sort_nodes()
		end
		if cur_node > 0 then 
			local node = system.find_node_by_id(cur_node)
			if node and ImGui.MenuItem("删 除") then 
				for i, v in ipairs(nodes) do 
					if v == node then 
						table.remove(nodes, i)
					end
				end
			end
		end
		ImGui.EndPopup();
	end

	draw_list.PushClipRect(min_x, min_y, max_x, max_y, true);
	local GRID_STEP = 60 * scale;
	local x = math.fmod(scrolling.x, GRID_STEP)
	while x < size_x do
		draw_list.AddLine({p1 = {min_x + x, min_y}, p2 = {min_x + x, max_y}, col = {0.8, 0.8, 0.8, 0.1}});
		x = x + GRID_STEP
	end 
	local y = math.fmod(scrolling.y, GRID_STEP)
	while y < size_y do 
		draw_list.AddLine({p1 = {min_x, min_y + y}, p2 = {max_x, min_y + y}, col = {0.8, 0.8, 0.8, 0.1}});
		y = y + GRID_STEP
	end
	draw_list.PopClipRect();
end

function system.draw_nodes()
	local wnd_posx, wnd_posy = ImGui.GetWindowPos()
	for _, data in ipairs(nodes) do 
		local id = "node_" .. data.id
		local posx = data.pos.x * scale + scrolling.x + wnd_posx
		local posy = data.pos.y * scale + scrolling.y + wnd_posy
		ImGui.SetCursorScreenPos(posx, posy);
		local min_x, min_y = posx, posy
		local sizex, sizey = node_width, node_height
		sizex = sizex * scale
		sizey = sizey * scale
		local max_x, max_y = min_x + sizex, min_y + sizey;
		data.rect = {min = {x = min_x, y = min_y}, max = {x = max_x, y = max_y}}
		ImGui.PushID(id)
		ImGui.BeginGroup()
		local col = cur_node == data.id and {0, 0.25, 0, 1} or {0.15, 0.15, 0.15, 1}
		draw_list.AddRectFilled({min = {min_x, min_y}, max = {max_x, max_y}, col = col});
		ImGui.Text("Id: " .. data.id)
		ImGui.Text("Order: " .. data.order)
		for i = 0, 7 do 
			blueprint.DrawPinIcon(i, false, 255, scale)
		end
		ImGui.EndGroup()
		ImGui.PopID()
	end
end

function system.process_mouse_event()
	if not is_canvas_hovered then return end 

	local io = ImGui.GetIO()
	local mouse_posx, mouse_posy = ImGui.GetMousePos()
	local wnd_posx, wnd_posy = ImGui.GetWindowPos()
	if io.MouseWheel ~= 0 then
		local pre_scale = scale
		if io.MouseWheel > 0 then 
			scale = math.min(1.5,  scale * 1.2)
		elseif io.MouseWheel < 0 then
			scale = math.max(0.2, scale * 0.8) 
		end
		if pre_scale ~= scale then 
			local mouse_real_x, mouse_real_y = mouse_posx - wnd_posx, mouse_posy - wnd_posy
			local factor = (pre_scale - scale) / pre_scale
			scrolling.x = scrolling.x + (mouse_real_x - scrolling.x) * factor
			scrolling.y = scrolling.y + (mouse_real_y - scrolling.y) * factor
		end
	end

	if ImGui.IsKeyDown(ImGui.Key.Space) then system.reset_view() end
	if ImGui.IsMouseDown(ImGui.MouseButton.Right) then is_dragged = false end
	
	local mouse_threshold_for_pan = -1
	if ImGui.IsMouseDragging(ImGui.MouseButton.Right, mouse_threshold_for_pan) then
		local delta_x, delta_y = ImGui.GetMouseDragDelta(ImGui.MouseButton.Right)
		scrolling.x = scrolling.x + delta_x;
		scrolling.y = scrolling.y + delta_y;
		ImGui.ResetMouseDragDeltaEx(ImGui.MouseButton.Right)
		is_dragged = true
	end

	if ImGui.IsMouseClicked(0) or ImGui.IsMouseClicked(1) then 
		local obj = system.get_mouse_hovered_obj()
		local node_id = -1
		if obj then 
			if obj.type == "node" then 
				node_id = obj.id
			end
		end
		if node_id ~= cur_node then 
			cur_node = node_id
			local node = system.find_node_by_id(cur_node)
			if node then 
				node.order = os.clock() 
				system.sort_nodes()
			end
		end
	end

	if ImGui.IsMouseDragging(ImGui.MouseButton.Left) then 
		local delta_x, delta_y = ImGui.GetMouseDragDelta(ImGui.MouseButton.Left, mouse_threshold_for_pan)
		ImGui.ResetMouseDragDeltaEx(ImGui.MouseButton.Left)

		local node = system.find_node_by_id(cur_node)
		if node then 
			node.pos.x =  node.pos.x + delta_x / scale
			node.pos.y =  node.pos.y + delta_y / scale
		end
	end
end

function system.get_mouse_hovered_obj()
	if not is_canvas_hovered then return end 
	local mouse_posx, mouse_posy = ImGui.GetMousePos()
	for _, data in ipairs(nodes) do 
		if mouse_posx >= data.rect.min.x and mouse_posx <= data.rect.max.x and mouse_posy >= data.rect.min.y and mouse_posy <= data.rect.max.y then
			return {type = "node", id = data.id}
		end
	end
end

function system.reset_view()
	if #nodes == 0 then return end 

	local first = nodes[1]
	local minx, miny = first.pos.x, first.pos.y
	local maxx, maxy = minx, miny
	for i = 2, #nodes do 
		local data = nodes[i]
		minx = math.min(minx, data.pos.x)
		miny = math.min(miny, data.pos.y)
		maxx = math.max(maxx, data.pos.x)
		maxy = math.max(maxy, data.pos.y)
	end
	maxx = maxx + node_width
	maxy = maxy + node_height

	local centerx, centery = (maxx + minx) * 0.5, (maxy + miny) * 0.5
	scrolling.x = region_x * 0.5 - centerx
	scrolling.y = region_y * 0.5 - centery
	scale = 1
end

function system.find_node_by_id(id)
	if not id or id <= 0 then return end 
	for _, data in ipairs(nodes) do 
		if data.id == id then 
			return data
		end
	end
end

function system.sort_nodes()
	table.sort(nodes, function(a, b) return a.order < b.order end)
end