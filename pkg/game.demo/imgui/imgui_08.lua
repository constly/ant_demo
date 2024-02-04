local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local ImGuiExtend = require "imgui.extend"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_08_system",
    category        = mgr.type_imgui,
    name            = "08_复制&粘贴",
    file            = "imgui/imgui_08.lua",
    ok              = true,
}
local system = mgr.create_system(tbParam)

local data_hander = {data = {}}
local map_size = 6
do 
	function data_hander.init()
		data_hander.data = {
			map = {},           -- 地图数据
			version = 1,        -- 数据版本号
			selected = {},      -- 当前选中的格子列表
		}
		for i = 1, map_size * map_size do 
			data_hander.data.map[i] = {id = 1}
		end
	end 
	function data_hander.add_selected(id)
		data_hander.data.selected[id] = true
		data_hander.data.last_idx = id
	end 
	function data_hander.reset_selected(id)
		data_hander.data.selected = {[id] = true}
		data_hander.data.last_idx = id
	end
	function data_hander.get_last_selected()
		return data_hander.data.last_idx
	end
	function data_hander.clear_map_grid(idx)
		if data_hander.data.map[idx] then 
			data_hander.data.map[idx] = {id = 1}
		end
	end
end 
data_hander.init()

local idx_to_x_y = function(idx)
	idx = idx - 1
	local y = idx % map_size
	local x = math.floor(idx / map_size)
	return x, y
end 

local x_y_to_idx = function(x, y)
	return x * map_size + y + 1;
end

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
do 
    function data_stack:undo()
        local index = self.index - 1
        if index >= 0 and index <= #self.stack then 
            self.index = index
            if self.index == 0 then 
                data_hander.init()
            else 
                data_hander.data = copy(self.stack[self.index])
            end
            print("undo", self.index)
        end
    end 
    function data_stack:redo()
        local index = self.index + 1
        if index >= 1 and index <= #self.stack then 
            self.index = index
            data_hander.data = copy(self.stack[self.index])
            print("redo", self.index)
        end
    end
    function data_stack:snapshoot()
        while(self.index >= 0 and #self.stack > self.index) do 
            table.remove(self.stack, #self.stack)
        end
        local new_data = copy(data_hander.data)
        table.insert(self.stack, new_data)
        self.index = #self.stack
        print("snapshoot", self.index)
    end
end

-- 剪切板
local clipboard = {mem = {}, is_cut = false}
do 
    function clipboard.copy()
        clipboard.is_cut = false
        clipboard.mem = copy(data_hander.data.selected)
		for i, v in pairs(clipboard.mem) do 
			clipboard.mem[i] = data_hander.data.map[i]
		end
    end 
    function clipboard.cut()
        clipboard.copy()
        clipboard.is_cut = true
    end 
    function clipboard.paste()
		local last_idx = data_hander.data.last_idx
		if not last_idx then return end
		local last_x, last_y = idx_to_x_y(last_idx)
		
		local from_min_x, from_min_y = map_size + 1, map_size + 1 
		for id, _ in pairs(clipboard.mem) do 
			local x, y = idx_to_x_y(id)
			from_min_x = math.min(x, from_min_x)
			from_min_y = math.min(y, from_min_y)
		end

		if from_min_x > map_size then return end
		for id, v in pairs(clipboard.mem) do 
			local x, y = idx_to_x_y(id)
			local offset_x, offset_y = x - from_min_x, y - from_min_y
			local new_x, new_y = last_x + offset_x, last_y + offset_y;
			if new_x <= map_size and new_y <= map_size then
				local new_idx = x_y_to_idx(new_x, new_y)
				print(x, y, new_x, new_y, new_idx)
				data_hander.data.map[new_idx] = copy(v)
			end
		end

		if clipboard.is_cut then
			for id, _ in pairs(clipboard.mem) do 
				data_hander.clear_map_grid(id)
			end
		end
		data_stack:snapshoot()
    end
end 

-- 定义格子类型
local tb_grid_def = {
    {name = "删 除", display="", bg = {0.18, 0.18, 0.18, 0.65}, text_col = {0.7, 0.7, 0.7, 0.7}},
    {name = "平 地", display="", bg = {0.4, 0.4, 0.4, 1}, text_col = {0, 0, 0, 0}},
    {name = "草 地", display="草地", bg = {0.45, 0.45, 0.45, 1}, text_col = {0, 0.9, 0, 1}},
    {name = "阻 挡", display="阻挡", bg = {0.8, 0, 0, 0.9}, text_col = {0.85, 0.85, 0.85, 1}},
} 
local cur_grid_id = 3
local tb_mode_def = {"画 刷", "普 通"}
local cur_mode_type = 1

local set_btn_style = function(name)
    if type(name) == "table" then 
        local cfg = name
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, cfg.bg[1], cfg.bg[2], cfg.bg[3], cfg.bg[4])
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, cfg.bg[1] * 1.2, cfg.bg[2] * 1.2, cfg.bg[3] * 1.2, cfg.bg[4])
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, cfg.bg[1] * 1.2, cfg.bg[2] * 1.2, cfg.bg[3] * 1.2, cfg.bg[4])
        ImGui.PushStyleColorImVec4(ImGui.Col.Text, cfg.text_col[1], cfg.text_col[2], cfg.text_col[3], cfg.text_col[4])
        return    
    end
    if name == "current" then 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0, 0.5, 0.7, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.1, 0.65, 0.8, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.1, 0.65, 0.8, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.9, 0.9, 0.9, 1)
    elseif name == "normal" then 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.9, 0.9, 0.9, 1)
    end
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then         
        ImGui.SetCursorPos(420, 15)
        ImGui.Text("简易地图编辑器")
        system.draw_grid_def()
        system.draw_editor_mode()
        system.draw_tips()
        system.draw_options()

        local draw_list = ImGuiExtend.draw_list;
        local offset_x = 210;
        local offset_y = 65;
        local gridsize = 90;
        local space = 5;
        local wnd_pox_x, wnd_pos_y = ImGui.GetWindowPos()
        for i, v in ipairs(data_hander.data.map) do
            local x, y = idx_to_x_y(i)
            local posx = x * (gridsize + space) + offset_x
            local posy = y * (gridsize + space) + offset_y
            ImGui.SetCursorPos(posx, posy)
            local grid_cfg = tb_grid_def[v.id]

            if cur_mode_type == 2 and data_hander.data.selected[i] then
                draw_list.AddRectFilled({
                    min = {posx + wnd_pox_x - 3, posy + wnd_pos_y - 3},
                    max = {posx + wnd_pox_x + gridsize + 3, posy + wnd_pos_y + gridsize + 3},
                    col = {0.1, 0.8, 0.1, 0.7}
                })    
            end

            set_btn_style(grid_cfg)
			local szId = ""
			if cur_mode_type == 1 and v.id == 1 then
				szId = string.format("%d, %d", x, y) 
			end
			local label = string.format("%s##btn_grid_%d", szId, i)
            if ImGui.ButtonEx(label, gridsize, gridsize) then 
                if cur_mode_type == 1 then
                    if v.id ~= cur_grid_id then
                        v.id = cur_grid_id
                        data_stack:snapshoot()
                    end
                else 
                    if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then
						data_hander.add_selected(i)
                        data_stack:snapshoot()
                    else 
						data_hander.reset_selected(i)
                        data_stack:snapshoot()
                    end
                end
            end 
            ImGui.PopStyleColorEx(4)

            if cur_mode_type == 2 and ImGui.BeginDragDropSource() then 
                ImGui.SetDragDropPayload("DragGrid", tostring(i));
                ImGui.Text(grid_cfg.name);
                ImGui.EndDragDropSource();
            end

            if cur_mode_type == 2 and ImGui.BeginDragDropTarget() then 
                local payload = ImGui.AcceptDragDropPayload("DragGridId")
                if payload then
                    local idx = tonumber(payload)
                    if idx and idx ~= v.id then 
                        v.id = idx
						data_hander.reset_selected(i)
                        data_stack:snapshoot()
                    end
                end
                payload = ImGui.AcceptDragDropPayload("DragGrid")
                if payload then
                    local idx = tonumber(payload)
					local data = data_hander.data 
                    data.map[i], data.map[idx] = data.map[idx], data.map[i]
                    data_hander.reset_selected(i)
                    data_stack:snapshoot()
                end
                ImGui.EndDragDropTarget()
			end

            if grid_cfg.display and grid_cfg.display ~= "" then 
                draw_list.AddText({pos = {posx + 30 + wnd_pox_x, posy + 30 + wnd_pos_y}, col = grid_cfg.text_col, text = grid_cfg.display})
            end
        end

	end 
	ImGui.End()    

    -- 快捷键
    if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
        if ImGui.IsKeyPressed(ImGui.Key.Z, false) then data_stack:undo() end
        if ImGui.IsKeyPressed(ImGui.Key.Y, false) then data_stack:redo() end
        if cur_mode_type == 2 then
        	if ImGui.IsKeyPressed(ImGui.Key.C, false) then clipboard.copy() end
        	if ImGui.IsKeyPressed(ImGui.Key.V, false) then clipboard.paste() end
        	if ImGui.IsKeyPressed(ImGui.Key.X, false) then clipboard.cut() end
        end
    end
	if cur_mode_type == 2 and ImGui.IsKeyPressed(ImGui.Key.Delete, false) then 
		if data_hander.data.last_idx then 
			data_hander.clear_map_grid(data_hander.data.last_idx) 
			data_stack:snapshoot()
		end 
	end
end

function system.draw_grid_def()
    ImGui.SetCursorPos(50, 300)
    ImGui.BeginGroup()
    ImGui.Text("格子定义")
    for i, v in ipairs(tb_grid_def) do 
        set_btn_style(i == cur_grid_id and "current" or "normal")
        if ImGui.ButtonEx(v.name, 100) then 
            cur_grid_id = i
        end
        if cur_mode_type == 2 and ImGui.IsItemHovered() and ImGui.BeginTooltip() then 
            ImGui.Text("拖我到地图中");
            ImGui.EndTooltip();
        end
        if cur_mode_type == 2 and ImGui.BeginDragDropSource() then 
            cur_grid_id = i
            ImGui.SetDragDropPayload("DragGridId", tostring(i));
            ImGui.Text(v.name);
            ImGui.EndDragDropSource();
        end
        ImGui.PopStyleColorEx(4)
    end
    ImGui.EndGroup();
end

function system.draw_editor_mode()
    ImGui.SetCursorPos(50, 100)
    ImGui.BeginGroup()
    ImGui.Text(" 编辑模式")
    for i, name in ipairs(tb_mode_def) do 
        set_btn_style( i == cur_mode_type and "current" or "normal")
        if ImGui.ButtonEx(name, 100) then 
            cur_mode_type = i
        end
        ImGui.PopStyleColorEx(4)
    end
    ImGui.EndGroup()

    ImGui.SetCursorPos(360, 650)
    if cur_mode_type == 1 then 
        ImGui.Text("画刷模式: 点击地图即可编辑")
    else 
        ImGui.Text("普通模式: 需拖动格子到地图中")
    end 
end

function system.draw_tips()
    ImGui.SetCursorPos(840, 100)
    ImGui.BeginGroup()
    ImGui.Text(" 操作说明:")
    ImGui.Text("Ctrl+Z 撤销")
    ImGui.Text("Ctrl+Y 前进")
    if cur_mode_type == 1 then
        local hint = "(需切换至普通模式)"
        ImGui.Text("Ctrl+C 复制" .. hint) 
        ImGui.Text("Ctrl+V 粘贴" .. hint)
        ImGui.Text("Ctrl+V 剪切" .. hint)
    else 
        ImGui.Text("Ctrl+C 复制")
        ImGui.Text("Ctrl+V 粘贴")
        ImGui.Text("Ctrl+V 剪切")
        ImGui.Text("Ctrl+点击 多选")
        ImGui.Text("Del 删除")
    end
    ImGui.EndGroup()
end

function system.draw_options()
    ImGui.SetCursorPos(840, 480)
    ImGui.BeginGroup()
    set_btn_style( "normal")
    if ImGui.ButtonEx("重 置", 100) then 
        data_hander.init()
        data_stack:snapshoot()
    end
    ImGui.ButtonEx("保 存", 100)
    ImGui.ButtonEx("加 载", 100)
    ImGui.PopStyleColorEx(4)
    ImGui.EndGroup()
end 