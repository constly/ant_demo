local ecs = ...
local ImGui  = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_10_system",
    category        = mgr.type_imgui,
    name            = "10_蓝图示例",
    file            = "imgui/imgui_10.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local ImGuiExtend = require "imgui.extend"
local draw_list = ImGuiExtend.draw_list
local scrolling = {x = 0.0, y = 0.0};
local is_dragged = false
local scale = 1
local nodes = {
	{pos = {x = 120, y = 120}}
}

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		local size_x, size_y = ImGui.GetContentRegionAvail();
		local left = 250

		ImGui.Text("开发中...")

		ImGui.SetCursorPos(left, 10)
		ImGui.BeginChild("##child_1", size_x - left, size_y, ImGui.ChildFlags({"None"}))
		system.draw_background();
		system.draw_nodes()
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
	local is_hovered = ImGui.IsItemHovered(); 
	local is_active = ImGui.IsItemActive();   

	local io = ImGui.GetIO()
	local mouse_posx, mouse_posy = ImGui.GetMousePos()
	local wnd_posx, wnd_posy = ImGui.GetWindowPos()
	if is_hovered and io.MouseWheel ~= 0 then
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

	if ImGui.IsKeyDown(ImGui.Key.Space) then 
		scale = 1
		scrolling.x = 0
		scrolling.y = 0
	end

	if ImGui.IsMouseDown(ImGui.MouseButton.Right) then 
		is_dragged = false
	end
	
	local mouse_threshold_for_pan = -1
	if (is_active and ImGui.IsMouseDragging(ImGui.MouseButton.Right, mouse_threshold_for_pan)) then
		local delta_x, delta_y = ImGui.GetMouseDragDelta(ImGui.MouseButton.Right)
		scrolling.x = scrolling.x + delta_x;
		scrolling.y = scrolling.y + delta_y;
		ImGui.ResetMouseDragDeltaEx(ImGui.MouseButton.Right)
		is_dragged = true
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
	ImGui.SetWindowFontScale(scale);

	for i, data in ipairs(nodes) do 
		local id = "node_" .. i
		local posx = data.pos.x * scale + scrolling.x + wnd_posx
		local posy = data.pos.y * scale + scrolling.y + wnd_posy
		ImGui.SetCursorScreenPos(posx, posy);
		local min_x, min_y = posx, posy
		local sizex, sizey = 100, 150
		sizex = sizex * scale
		sizey = sizey * scale
		local max_x, max_y = min_x + sizex, min_y + sizey;
		ImGui.PushID(id)
		ImGui.BeginGroup()
		draw_list.AddRectFilled({min = {min_x, min_y}, max = {max_x, max_y}, col = {0.15, 0.15, 0.15, 1}});
		ImGui.Text("文本1")
		ImGui.Text("文本2")
		ImGui.EndGroup()
		ImGui.PopID()
	end
	

	ImGui.SetWindowFontScale(1);
end