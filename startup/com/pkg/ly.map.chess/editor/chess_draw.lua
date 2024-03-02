---------------------------------------------------------------------------
-- 编辑器绘制
---------------------------------------------------------------------------
local dep = require 'dep' ---@type ly.map.chess.dep 
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils
local chess_region_draw = require 'editor/chess_region_draw'

---@param editor chess_editor
local create = function(editor)
	---@class chess_editor_draw
	local chess = {}
	local region_draw = chess_region_draw.create(editor)
	local input_content = ImGui.StringBuf()

	function chess.on_render(_deltatime)
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 0, 0)
		local start_x = 3
		local fix_x, fix_y = 6, 7;
		ImGui.SetCursorPos(start_x, 0)
		local size_x, size_y = ImGui.GetContentRegionMax()
		local size_left = 150;
		local size_right = 150;
		local offset_x = 0
		size_y = size_y + fix_y
		ImGui.BeginChild("##chess_left", size_left, size_y, ImGui.ChildFlags({"Border"}))
			chess.draw_left()
		ImGui.EndChild()

		ImGui.SetCursorPos(size_left + offset_x + start_x, 0)
		local size = size_x - size_left - size_right - 2 * offset_x
		ImGui.BeginChild("##chess_middle", size, size_y, ImGui.ChildFlags({"Border"}))
			chess.draw_middle(_deltatime)
		ImGui.EndChild()

		ImGui.SetCursorPos(size_left + size + offset_x * 2 + start_x, 0)
		ImGui.BeginChild("##chess_right", size_right + fix_x, size_y, ImGui.ChildFlags({"Border"}))
			chess.draw_right()
		ImGui.EndChild()
		ImGui.PopStyleVar()
	end

	function chess.draw_left()
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.Dummy(2, 3);
		imgui_utils.draw_text_center("物件列表")

		local h1 = size_y * 0.7
		ImGui.BeginChild("##chess_left_1", size_x, h1, ImGui.ChildFlags({"Border"}))
			
		ImGui.EndChild()

		ImGui.Dummy(5, 3);
		imgui_utils.draw_text_center("区 域")
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("##chess_left_2", size_x, size_y, ImGui.ChildFlags({"Border"}))
			
		ImGui.EndChild()
	end

	function chess.draw_middle(_deltatime)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(3, 4)
		imgui_utils.draw_btn("设置", false)
		ImGui.SameLine()
		imgui_utils.draw_btn("配置", false)

		local region = editor.data_hander.cur_region()
		local offset = #region.layers * 30
		ImGui.SameLineEx(size_x * 0.5 - offset * 0.5)
	
		--ImGui.SameLine()
		for i, v in ipairs(region.layers) do 
			local str = v.height and tostring(v.height) or "L"
			if #str == 1 then str = " " .. str .. " " end
			local label = string.format("%s##id_btn_layer_%d", str, i)
			if imgui_utils.draw_btn(label, v.active) then 
				v.active = not v.active
				editor.stack.snapshoot(false)
			end

			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 5, 5)
			local modify_h = false
			if ImGui.BeginPopupContextItem("layer_pop") then 
				if v.height then 
					ImGui.Text("高度: " .. v.height)
				else 
					local height = editor.data_hander.get_logic_layer_height(region, v)
					ImGui.Text("逻辑层级, 高度: " .. height)
				end
				if #region.layers > 0 and ImGui.MenuItem("删 除") then 
					table.remove(region.layers, i)
					editor.stack.snapshoot(true)
				end
				if i > 1 and ImGui.MenuItem("前 移") then 
					local v = table.remove(region.layers, i)
					table.insert(region.layers, i - 1, v)
					editor.stack.snapshoot(true)
				end
				if i < #region.layers and ImGui.MenuItem("后 移") then 
					local v = table.remove(region.layers, i)
					table.insert(region.layers, i + 1, v)
					editor.stack.snapshoot(true)
				end
				if v.height and ImGui.MenuItem("修改高度") then 
					modify_h = true;
				end
				if v.height and ImGui.MenuItem("添加逻辑层级") then 
					local tb = editor.data_hander.create_region_layer(nil, false)
					table.insert(region.layers, i + 1, tb)
					editor.stack.snapshoot(true)
				end
				ImGui.EndPopup()
			end
			local pop_label = string.format("修改层级高度##modify_layer_height_%d", i)
			if modify_h then 
				ImGui.OpenPopup(pop_label, ImGui.PopupFlags { "None" });
				input_content:Assgin(tostring(v.height))
			end
			if ImGui.BeginPopupModal(pop_label, true, ImGui.WindowFlags{"AlwaysAutoResize"} ) then
				ImGui.SameLineEx(50)
				ImGui.Text("高度: ")
				ImGui.SameLine()
				ImGui.SetNextItemWidth(80)
				ImGui.InputText("##input_height", input_content)
				ImGui.SameLine()
				ImGui.Dummy(50, 20)
				ImGui.Separator();
				ImGui.NewLine()
				ImGui.NewLine()
				ImGui.SameLineEx(50)
				if ImGui.ButtonEx("确 认", 60) then 
					v.height = tonumber(tostring(input_content))
					editor.stack.snapshoot(true)
					ImGui.CloseCurrentPopup()
				end
				ImGui.SameLine()
				if ImGui.ButtonEx("取 消", 60) then 
					ImGui.CloseCurrentPopup()
				end
				ImGui.EndPopup();
			end

			ImGui.PopStyleVar()

			ImGui.SameLine()
		end
		ImGui.SameLine()
		if imgui_utils.draw_btn(" + ##add_layer2") then 
			ImGui.OpenPopup("layer_pop2", ImGui.PopupFlags { "None" });
		end
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 5, 5)
		if ImGui.BeginPopupContextItemEx("layer_pop2") then 
			if ImGui.MenuItem("前增层级") then 
				local height = editor.data_hander.get_next_height(region, 1, -1)
				local tb = editor.data_hander.create_region_layer(height, true)
				table.insert(region.layers, 1, tb)
				editor.stack.snapshoot(true)
			end
			if ImGui.MenuItem("后增层级") then 
				local height = editor.data_hander.get_next_height(region, #region.layers, 1)
				local tb = editor.data_hander.create_region_layer(height, true)
				table.insert(region.layers, tb)
				editor.stack.snapshoot(true)
			end
			ImGui.EndPopup()
		end
		ImGui.PopStyleVar()
		
		local top = 31
		size_y = size_y - top
		ImGui.SetCursorPos(0, top)
		ImGui.BeginChild("##chess_middle_2", size_x, size_y, ImGui.ChildFlags({"Border"}))
			region_draw.on_render(_deltatime)
		ImGui.EndChild()
	end

	function chess.draw_right()
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.Dummy(2, 1);
		ImGui.Dummy(20, 3);
		ImGui.SameLine()
		imgui_utils.draw_btn("保 存", false)
		ImGui.SameLine()
		imgui_utils.draw_btn("清 空", false)
		local top = 31
		size_y = size_y - top
		ImGui.SetCursorPos(0, top)
		ImGui.BeginChild("##chess_right_1", size_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.Text("Inspector");
		ImGui.EndChild()
	end

	return chess
end 

return {create = create}