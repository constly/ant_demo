local ecs = ...
local dep = require "dep"
local ImGui = dep.ImGui
local ImGuiExtend = dep.ImGuiExtend
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_07_system",
    category        = mgr.type_imgui,
    name            = "07_撤销&回退",
    file            = "imgui/imgui_07.lua",
    ok              = true,
}
local system = mgr.create_system(tbParam)
local scrolling = {x = 0.0, y = 0.0};
local adding_line = false
local opt_enable_grid = {true};
local opt_enable_context_menu = {true};

local data = {points = {}}
local is_dragged = false

-- 深拷贝table
local copy;
copy = function(tb)
	local ret = {};
	if type(tb) ~= "table" then
		return tb;
	end
	for k, v in pairs(tb) do
		if type(v) == "table" then
			ret[k] = copy(v);
		else
			ret[k] = v;
		end
	end
	return ret;
end

-- 数据堆栈
local data_stack = {index = 0, stack = {}}
function data_stack:undo()
    local index = self.index - 1
    if index >= 0 and index <= #self.stack then 
        self.index = index
        if self.index == 0 then 
            data = {points = {}}
        else 
            data = copy(self.stack[self.index])
        end
        print("undo", self.index)
    end
end 
function data_stack:redo()
    local index = self.index + 1
    if index >= 1 and index <= #self.stack then 
        self.index = index
        data = copy(self.stack[self.index])
        print("redo", self.index)
    end
end
function data_stack:snapshoot()
    while(self.index >= 0 and #self.stack > self.index) do 
        table.remove(self.stack, #self.stack)
    end
    local new_data = copy(data)
    table.insert(self.stack, new_data)
    self.index = #self.stack
    print("snapshoot", self.index)
end

function system.on_entry()
	if #data.points == 0 then 
		table.insert(data.points, {x = 314, y = 162})
		table.insert(data.points, {x = 171, y = 446})
		data_stack:snapshoot()
		table.insert(data.points, {x = 319, y = 165})
		table.insert(data.points, {x = 407, y = 407})
		data_stack:snapshoot()
		table.insert(data.points, {x = 229, y = 347})
		table.insert(data.points, {x = 361, y = 337})
		data_stack:snapshoot()
	end
end

function system.data_changed()
    ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
        
        if ImGui.Checkbox("Enable grid", opt_enable_grid) then 
            --opt_enable_grid = not opt_enable_grid 
        end 
        ImGui.SameLine()
        if ImGui.Checkbox("Enable context menu", opt_enable_context_menu) then 
            --opt_enable_context_menu = not opt_enable_context_menu
        end
        local undo_desc = string.format("Ctrl+Z, Ctrl+Y: 撤销和回退；当前数据堆栈: %d / %d", data_stack.index, #data_stack.stack)
        ImGui.Text("Mouse Left: drag to add lines,\nMouse Right: drag to scroll, click for context menu.\n" .. undo_desc);

        local min_x, min_y = ImGui.GetCursorScreenPos();      -- ImDrawList API uses screen coordinates!
        local size_x, size_y = ImGui.GetContentRegionAvail();
        local max_x, max_y = min_x + size_x, min_y + size_y;   
          
        -- Draw border and background color
        local draw_list = ImGuiExtend.draw_list
        draw_list.AddRectFilled({min = {min_x, min_y}, max = {max_x, max_y}, col = {0.25, 0.25, 0.25, 1}});
        draw_list.AddRect({min = {min_x, min_y}, max = {max_x, max_y}, col = {1, 1, 1, 1}});

        -- This will catch our interactions
        ImGui.InvisibleButton("canvas", size_x, size_y, ImGui.ButtonFlags{ "MouseButtonLeft", "MouseButtonRight"} );
        local is_hovered = ImGui.IsItemHovered(); 
        local is_active = ImGui.IsItemActive();   
        local origin = {x = min_x + scrolling.x, y = min_y + scrolling.y}; 
        local mouse_x, mouse_y = ImGui.GetMousePos()
        local mouse_pos_in_canvas = {x = mouse_x - origin.x, y = mouse_y - origin.y};

        -- Add first and second point
        if (is_hovered and not adding_line and ImGui.IsMouseClicked(ImGui.MouseButton.Left)) then
            table.insert(data.points, mouse_pos_in_canvas);
            table.insert(data.points, mouse_pos_in_canvas);
            adding_line = true;
        end 

        if (adding_line) then
            data.points[#data.points] = mouse_pos_in_canvas
            if not ImGui.IsMouseDown(ImGui.MouseButton.Left) then 
                adding_line = false;
                data_stack:snapshoot()
            end
        end

		if ImGui.IsMouseDown(ImGui.MouseButton.Right) then is_dragged = false  end

        -- Pan (we use a zero mouse threshold when there's no context menu)
        -- You may decide to make that threshold dynamic based on whether the mouse is hovering something etc.
        local mouse_threshold_for_pan = opt_enable_context_menu[1] and -1.0 or 0.0;
        if (is_active and ImGui.IsMouseDragging(ImGui.MouseButton.Right, mouse_threshold_for_pan)) then
            local delta_x, delta_y = ImGui.GetMouseDragDelta(ImGui.MouseButton.Right)
            scrolling.x = scrolling.x + delta_x;
            scrolling.y = scrolling.y + delta_y;
			ImGui.ResetMouseDragDeltaEx(ImGui.MouseButton.Right)
			is_dragged = true
        end

        -- Context menu (under default mouse threshold)
        if (opt_enable_context_menu[1] and not is_dragged and ImGui.IsMouseReleased(ImGui.MouseButton.Right)) then
            ImGui.OpenPopupOnItemClick("context", ImGui.PopupFlags{"MouseButtonRight"});
        end
        if ImGui.BeginPopup("context") then 
            if adding_line then
                table.remove(data.points, #data.points)
                table.remove(data.points, #data.points)
            end
            adding_line = false;
            if ImGui.MenuItem("Remove one", nil, false, #data.points > 0) then 
                table.remove(data.points, #data.points)
                table.remove(data.points, #data.points)
                data_stack:snapshoot()
            end
            if ImGui.MenuItem("Remove all", nil, false, #data.points > 0) then 
                data.points = {};  
                data_stack:snapshoot()
            end
            ImGui.EndPopup();
        end

        -- Draw grid + all lines in the canvas
        draw_list.PushClipRect(min_x, min_y, max_x, max_y, true);
        if opt_enable_grid[1] then
            local GRID_STEP = 64.0;
            local x = math.fmod(scrolling.x, GRID_STEP)
            while x < size_x do
                draw_list.AddLine({p1 = {min_x + x, min_y}, p2 = {min_x + x, max_y}, col = {0.8, 0.8, 0.8, 0.18}});
                x = x + GRID_STEP
            end 
            local y = math.fmod(scrolling.y, GRID_STEP)
            while y < size_y do 
                draw_list.AddLine({p1 = {min_x, min_y + y}, p2 = {max_x, min_y + y}, col = {0.8, 0.8, 0.8, 0.18}});
                y = y + GRID_STEP
            end
        end
        for n = 1, #data.points, 2 do 
            local p1 = data.points[n]
            local p2 = data.points[n + 1]
            draw_list.AddLine({p1 = {origin.x + p1.x, origin.y + p1.y}, p2 = {origin.x + p2.x, origin.y + p2.y}, col = {1, 1, 0, 1}, thickness = 2.0});
        end
        draw_list.PopClipRect();
    end
    ImGui.End();

    -- 检查快捷键
    if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) and ImGui.IsKeyPressed(ImGui.Key.Z, false) then 
        data_stack:undo()
    end
    
    if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) and ImGui.IsKeyPressed(ImGui.Key.Y, false) then 
        data_stack:redo()
    end

	if ImGui.IsKeyPressed(ImGui.Key.P, false) then 
		dep.common.lib.dump(data.points)
	end
end