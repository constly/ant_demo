---------------------------------------------------------------------------
-- 编辑器主框架绘制
---------------------------------------------------------------------------
local dep = require 'dep' ---@type ly.game_editor.dep 
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils
local chess_region_draw = require 'windows.map.chess_region_draw'
local chess_inspector_draw = require 'windows.map.chess_inspector'

---@param editor ly.game_editor.editor
---@param renderer ly.map.renderer
local function create(editor, renderer)
	---@class chess_editor_draw
	local chess = {}
	local region_draw = chess_region_draw.new(editor, renderer)
	local input_content = ImGui.StringBuf()
	local inspector = chess_inspector_draw.new(editor, renderer)
	
	---@type ly.map.chess.ui_setting
	local ui_setting = require 'windows.map.ui.chess_ui_setting'.new(renderer)

	local dpiScale
	local header_y
	chess.region_draw = region_draw

	function chess.on_destroy()
		region_draw.on_destroy()
	end

	function chess.on_render(_deltatime)
		dpiScale = ImGui.GetMainViewport().DpiScale
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 0, 0)
		local start_x = 0
		local fix_x, fix_y = 6, 7;
		ImGui.SetCursorPos(start_x, 0)
		local size_x, size_y = ImGui.GetContentRegionMax()
		local size_left = 165 * dpiScale;
		local size_right = 150 * dpiScale;
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
			chess.draw_right(_deltatime)
		ImGui.EndChild()
		ImGui.PopStyleVar()

		ui_setting.update()
	end

	function chess.draw_left()
		local len = 135 * dpiScale;
		local data = renderer.data_hander.data
		ImGui.Dummy(2, 3);
		imgui_utils.draw_text_center("物件列表")
		header_y = ImGui.GetCursorPosY()

		local x, y = ImGui.GetCursorPos()
		ImGui.SetCursorPos(x + 5, y)
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
		ImGui.BeginGroup()
		for i, def in ipairs(renderer.tb_object_def or {}) do 
			local label = string.format("[%d] %s(%d*%d)##btn_obj_def_%d", def.id, def.name, def.size.x, def.size.y, def.id)
			local r, g, b, a = def.bg_color[1], def.bg_color[2], def.bg_color[3], def.bg_color[4]
			ImGui.ColorButtonEx("", r, g, b, a, nil, 13)
			ImGui.SameLineEx(16)
			if imgui_utils.draw_btn(label, data.cur_object_id == def.id, {size_x = len}) then 
				if data.cur_object_id ~= def.id then 
					data.cur_object_id = def.id
					renderer.stack.snapshoot(false)
				end
			end
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 5, 5)
			if ImGui.BeginDragDropSource() then 
				renderer.isPuttingObject = true
				data.cur_object_id = def.id
				ImGui.SetDragDropPayload("PutObject", tostring(def.id));
				ImGui.Text("正在拖动 " .. def.name .. " 到层级1");
				ImGui.EndDragDropSource();	
			end
			ImGui.PopStyleVar()
		end	
		ImGui.Dummy(10, 10)
		ImGui.EndGroup()
		ImGui.PopStyleVar()
	end

	function chess.draw_middle(_deltatime)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(3, 4)
		if imgui_utils.draw_btn("清 空", false) then 
			renderer.on_reset()
		end
		ImGui.SameLine()
		if imgui_utils.draw_btn("还 原", false) then 
			renderer.on_init()
		end
		ImGui.SameLineEx(size_x - 100)
		if imgui_utils.draw_btn("事 件", false) then 
			editor.msg_hints.show("点击事件", "warning")
		end
		ImGui.SameLine()
		if imgui_utils.draw_btn("设 置", false) then 
			ui_setting.open()
		end

		local region = renderer.data_hander.cur_region()
		local offset = #region.layers * 30
		ImGui.SameLineEx(size_x * 0.5 - offset * 0.5)
	
		--ImGui.SameLine()
		for i, v in ipairs(region.layers) do 
			local str = tostring(v.height)
			if #str == 1 then str = " " .. str .. " " end
			local label = string.format("%s##id_btn_layer_%d", str, i)
			if imgui_utils.draw_btn(label, v.active) then 
				v.active = not v.active
				renderer.stack.snapshoot(false)
			end

			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 5, 5)
			local modify_h = false
			if ImGui.BeginPopupContextItem("layer_pop") then 
				renderer.data_hander.clear_all_selected_layer(region)
				v.active = true;
				ImGui.Text("层级高度: " .. v.height)
				if ImGui.MenuItem("修改高度") then 
					modify_h = true;
				end
				ImGui.Separator()
				if #region.layers > 1 and ImGui.MenuItem("删 除") then 
					table.remove(region.layers, i)
					renderer.stack.snapshoot(true)
				end
				ImGui.Separator()
				if i > 1 and ImGui.MenuItem("前 移") then 
					local v = table.remove(region.layers, i)
					table.insert(region.layers, i - 1, v)
					renderer.stack.snapshoot(true)
				end
				if i < #region.layers and ImGui.MenuItem("后 移") then 
					local v = table.remove(region.layers, i)
					table.insert(region.layers, i + 1, v)
					renderer.stack.snapshoot(true)
				end
				ImGui.Separator()
				if ImGui.MenuItem("前 增") then 
					renderer.data_hander.clear_all_selected_layer(region)
					local tb = renderer.data_hander.create_region_layer(v.height - 1, true)
					table.insert(region.layers, i, tb)
					renderer.stack.snapshoot(true)
				end
				if ImGui.MenuItem("后 增") then 
					renderer.data_hander.clear_all_selected_layer(region)
					local tb = renderer.data_hander.create_region_layer(v.height + 1, true)
					table.insert(region.layers, i + 1, tb)
					renderer.stack.snapshoot(true)
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
					renderer.stack.snapshoot(true)
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
		
		local top = header_y
		size_y = size_y - top
		ImGui.SetCursorPos(0, top)
		ImGui.BeginChild("##chess_middle_2", size_x, size_y, ImGui.ChildFlags({"Border"}))
			region_draw.on_render(_deltatime)
		ImGui.EndChild()
	end

	function chess.draw_right(_deltatime)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local top = header_y
		size_y = size_y - top
		ImGui.SetCursorPos(0, top)
		ImGui.BeginChild("##chess_right_1", size_x, size_y, ImGui.ChildFlags({"Border"}))
			inspector.on_render(_deltatime)
		ImGui.EndChild()
	end

	return chess
end 

return {create = create}