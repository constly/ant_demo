---------------------------------------------------------------------------
-- 编辑器主框架绘制
---------------------------------------------------------------------------
local dep = require 'dep' ---@type ly.map.chess.dep 
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils
local imgui_styles = dep.common.imgui_styles
local chess_region_draw = require 'editor/chess_region_draw'
local chess_inspector_draw = require 'editor/chess_inspector'

---@param editor chess_editor
local create = function(editor)
	---@class chess_editor_draw
	local chess = {}
	local region_draw = chess_region_draw.create(editor)
	local input_content = ImGui.StringBuf()
	local inspector = chess_inspector_draw.create(editor)

	function chess.on_destroy()
		region_draw.on_destroy()
	end

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
			chess.draw_right(_deltatime)
		ImGui.EndChild()
		ImGui.PopStyleVar()
	end

	function chess.draw_left()
		local len = 135;
		local data = editor.data_hander.data
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.Dummy(2, 3);
		imgui_utils.draw_text_center("物件列表")

		local h1 = size_y * 0.7
		ImGui.BeginChild("##chess_left_1", size_x, h1, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(5, 5)
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
			ImGui.BeginGroup()
			for i, def in ipairs(editor.args.tb_objects) do 
				local label = string.format("L%d: [%d]%s(%d*%d)##btn_obj_def_%d", def.nLayer or 1, def.id, def.name, def.size.x, def.size.y, def.id)
				if imgui_utils.draw_btn(label, data.cur_object_id == def.id, {size_x = len}) then 
					if data.cur_object_id ~= def.id then 
						data.cur_object_id = def.id
						editor.stack.snapshoot(false)
					end
				end
				ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 5, 5)
				if ImGui.BeginDragDropSource() then 
					editor.isPuttingObject = true
					data.cur_object_id = def.id
					ImGui.SetDragDropPayload("PutObject", tostring(def.id));
					ImGui.Text("正在拖动 " .. def.name .. " 到层级1");
					ImGui.EndDragDropSource();	
				end
				ImGui.PopStyleVar()
	
			end	
			ImGui.EndGroup()
			ImGui.PopStyleVar()
		ImGui.EndChild()

		ImGui.Dummy(5, 3);
		imgui_utils.draw_text_center("区域列表")
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("##chess_left_2", size_x, size_y, ImGui.ChildFlags({"Border"}))
			local regions = data.regions
			ImGui.SetCursorPos(5, 5)
			ImGui.BeginGroup()
			local count = #regions + 1
			for i = 1, count do 
				if i < count then 
					local label = string.format("区域 %d##btn_region_idx_%d", i, i)
					if imgui_utils.draw_btn(label, i == data.region_index, {size_x = len}) and i ~= data.region_index then 
						data.region_index = i
						editor.stack.snapshoot(false)
					end
					ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 5, 5)
					if count > 2 and ImGui.BeginPopupContextItem() then 
						data.region_index = i
						if ImGui.MenuItem("删 除") then 
							table.remove(regions, i)
							if data.region_index > #regions then
								data.region_index = #regions
							end
							editor.stack.snapshoot(true)
						end
						ImGui.EndPopup()
					end
					ImGui.PopStyleVar()
				else 
					local label = "+##btn_region_add"
					if imgui_utils.draw_btn(label, false, {size_x = len}) then 
						local region = editor.data_hander.create_region()
						table.insert(data.regions, region)
						data.region_index = #data.regions
						editor.stack.snapshoot(true)
					end
				end
			end
			ImGui.EndGroup()
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
			local str = tostring(v.height)
			if #str == 1 then str = " " .. str .. " " end
			local label = string.format("%s##id_btn_layer_%d", str, i)
			if imgui_utils.draw_btn(label, v.active) then 
				v.active = not v.active
				editor.stack.snapshoot(false)
			end

			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 5, 5)
			local modify_h = false
			if ImGui.BeginPopupContextItem("layer_pop") then 
				editor.data_hander.clear_all_selected_layer(region)
				v.active = true;
				ImGui.Text("层级高度: " .. v.height)
				if ImGui.MenuItem("修改高度") then 
					modify_h = true;
				end
				ImGui.Separator()
				if #region.layers > 1 and ImGui.MenuItem("删 除") then 
					table.remove(region.layers, i)
					editor.stack.snapshoot(true)
				end
				ImGui.Separator()
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
				ImGui.Separator()
				if ImGui.MenuItem("前 增") then 
					editor.data_hander.clear_all_selected_layer(region)
					local tb = editor.data_hander.create_region_layer(v.height - 1, true)
					table.insert(region.layers, i, tb)
					editor.stack.snapshoot(true)
				end
				if ImGui.MenuItem("后 增") then 
					editor.data_hander.clear_all_selected_layer(region)
					local tb = editor.data_hander.create_region_layer(v.height + 1, true)
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
		
		local top = 31
		size_y = size_y - top
		ImGui.SetCursorPos(0, top)
		ImGui.BeginChild("##chess_middle_2", size_x, size_y, ImGui.ChildFlags({"Border"}))
			region_draw.on_render(_deltatime)
		ImGui.EndChild()
	end

	function chess.draw_right(_deltatime)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(3.5, 5)
		if imgui_utils.draw_btn("Reload", false) then 
			editor.on_init()
		end
		ImGui.SameLine()
		if imgui_utils.draw_btn("Save", false) then 
			editor.on_save(function(content)
				local f<close> = assert(io.open(editor.args.path, "w"))
    			f:write(content)
			end)
		end
		ImGui.SameLine()
		if imgui_utils.draw_btn("Clear", false) then 
			editor.on_reset()
		end
		local top = 31
		size_y = size_y - top
		ImGui.SetCursorPos(0, top)
		ImGui.BeginChild("##chess_right_1", size_x, size_y, ImGui.ChildFlags({"Border"}))
			inspector.on_render(_deltatime)
		ImGui.EndChild()
	end

	return chess
end 

return {create = create}