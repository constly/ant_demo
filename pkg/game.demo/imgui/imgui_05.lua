local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_05_system",
    category        = mgr.type_imgui,
    name            = "05_拖拽",
    desc            = "演示如何使用鼠标拖动控件",
    file            = "imgui/imgui_05.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)
local items = {}

function system.on_entry()
	items = {}
	for i = 1, 9 do
		table.insert(items, i)
	end
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", ImGui.WindowFlags {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar"}) then 
		local offset_x = 150;
		local offset_y = 50

		ImGui.SetCursorPos(260 + offset_x, 20 + offset_y)
		ImGui.Text("试试拖动")

		ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)

		local idx_hover 
		local x, y = ImGui.GetCursorPos()
		for i, v in ipairs(items) do 
			local x = (i - 1) % 3
			local y = math.ceil(i / 3)
			local xpos = 120 * x + 120 + offset_x
			local ypos = 120 * y - 50 + offset_y
			ImGui.SetCursorPos(xpos, ypos)
			local label = string.format("##btn_l_%d", i)
			ImGui.Button(label, 100, 100)

			if ImGui.BeginDragDropSource() then 
				ImGui.SetDragDropPayload("DragNode", tostring(i));
				ImGui.Text("正在拖动 " .. v);
				ImGui.EndDragDropSource();
			end

			if ImGui.BeginDragDropTarget() then 
				local payload = ImGui.AcceptDragDropPayload("DragNode")
            	if payload then
					local idx = tonumber(payload)
					if idx then 
						items[i], items[idx] = items[idx], items[i]
					end
				end
				ImGui.EndDragDropTarget()
			end

			-- 计算当前拖动目标
			if ImGui.IsMouseDragging(0) then 
				local x, y = ImGui.GetMousePos()
				local wnd_pox_x, wnd_pos_y = ImGui.GetWindowPos()
				local delta_x = x - (xpos + wnd_pox_x)  -- 计算屏幕上鼠标位置 距离 格子左上角的偏移
				local delta_y = y - (ypos + wnd_pos_y)
				if delta_x >= 0 and delta_x < 100 and delta_y >= 0 and delta_y < 100 then 
					idx_hover = i
				end
			end
		end

		-- 绘制格子上的数字
		for i, v in ipairs(items) do 
			local payload = ImGui.GetDragDropPayload("DragNode")
			if not payload or tonumber(payload) ~= i then 
				local x = (i - 1) % 3 
				local y = math.ceil(i / 3)
				local xpos = 120 * x + 120 + 45 + offset_x
				local ypos = 120 * y - 50 + 40 + offset_y
				ImGui.SetCursorPos(xpos, ypos)

				if idx_hover == i then 
					ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.1, 0.9, 0.1, 1)
				else 
					ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.9, 0.9, 0.9, 1)
				end
				ImGui.Text(v)
				ImGui.PopStyleColor(1)
			end
		end

		ImGui.PopStyleColor(3)
    end
    ImGui.End()
end