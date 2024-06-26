--------------------------------------------------------
-- 窗口 收藏列表
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ImGui = dep.ImGui
local lib = dep.common.lib
local ImGuiExtend = dep.ImGuiExtend
local draw_list = ImGuiExtend.draw_list

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.wnd_portal
	local api = {}
	local hover_idx = 0;

	function api.update(is_active, delta_time)
		local dpi = dep.common.imgui_utils.get_dpi_scale()
		ImGui.SetCursorPos(5, 3)
		ImGui.BeginGroup()
		local portal = editor.portal
		for i, p in ipairs(portal.pages) do 
			local label = string.format("  P%d  ##btn_page_%d", i, i)
			if editor.style.draw_btn(label, portal.cur_page == i) then 
				portal.set_page(i)
			end
			ImGui.SameLine()
		end
		ImGui.EndGroup()
		local line_y = ImGui.GetCursorPosY()
		ImGui.SetCursorPos(0, line_y)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("wnd_portal_content", size_x, size_y, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(8, 5)
		local list = portal.pages[portal.cur_page] or {}
		local wnd_files = editor.wnd_files
		local txt_size = ImGui.CalcTextSize(" 打 开 ")
		local btn_size = txt_size + 18
		ImGui.BeginGroup()
		for i, path in ipairs(list) do 
			local name = lib.get_file_name(path)
			local ext = lib.get_file_ext(path) or "folder"
			local id = wnd_files.get_icon_id_by_ext(ext) or 0
			ImGui.BeginGroup()
			local x, y = ImGui.GetCursorScreenPos()
			if i == hover_idx then 
				draw_list.AddRectFilled({min = {x, y}, max = {x + size_x - 10, y + line_y - 5}, col = {0.25, 0.25, 0.25, 1}});                                    
			end
			local img_size = 23 * dpi
			ImGui.Image(dep.textureman.texture_get(id), img_size, img_size)
			ImGui.SameLineEx(40)
			if editor.style.draw_style_btn(name .. "##btn_none", GStyle.btn_transp_center) then 
			end
			ImGui.SameLineEx(size_x - btn_size * 2)
			if editor.style.draw_btn(" 打 开 ##btn_portal_open_" .. i, true) then 
				if ext == "folder" then 
					editor.wnd_files.browse(path)
				else 
					editor.open_tab(path)
				end
			end
			ImGui.SameLine()
			if editor.style.draw_btn(" 选 中 ##btn_portal_browse_" .. i) then 
				editor.wnd_files.browse(path)
			end
			ImGui.EndGroup()
			local label = "popup_item_modal_" .. i
			ImGui.OpenPopupOnItemClick(label, 1);
			if ImGui.IsItemHovered() then 
				hover_idx = i
			end
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
			if ImGui.BeginPopupContextItemEx(label) then 
				if i > 1 and ImGui.MenuItem(" 上 移 ") then 
					table.remove(list, i)
					table.insert(list, i - 1, path)
					portal.save()
				end
				if i > 1 and ImGui.MenuItem(" 置 顶 ") then 
					table.remove(list, i)
					table.insert(list, 1, path)
					portal.save()
				end
				if i < #list then
					if i > 1 then 
						ImGui.Separator()
					end
					if ImGui.MenuItem(" 下 移 ") then 
						table.remove(list, i)
						table.insert(list, i + 1, path)
						portal.save()
					end
					if ImGui.MenuItem(" 置 底 ") then 
						table.remove(list, i)
						table.insert(list, path)
						portal.save()
					end
				end
				if #list > 1 then
					ImGui.Separator()
				end
				if ImGui.MenuItem(" 移 除 ") then 
					table.remove(list, i)
					portal.save()
				end
				ImGui.EndPopup();
			end
			ImGui.PopStyleVar()
		end		
		ImGui.Dummy(10, 5)
		ImGui.EndGroup()
		ImGui.EndChild()
	end

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return false
	end

	function api.close()
	end 

	function api.save()
	end 

	return api
end

return {new = new}