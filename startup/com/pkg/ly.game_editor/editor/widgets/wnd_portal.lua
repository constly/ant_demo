--------------------------------------------------------
-- 窗口 收藏列表
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local imgui_utils = dep.common.imgui_utils
local imgui_styles = dep.common.imgui_styles
local ImGui = dep.ImGui
local lib = dep.common.lib
local ImGuiExtend = dep.ImGuiExtend
local draw_list = ImGuiExtend.draw_list

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.wnd_portal
	local api = {}
	local hover_idx = 0;

	function api.draw(deltatime, line_y)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(5, 3)
		ImGui.BeginGroup()
		local portal = editor.portal
		for i, p in ipairs(portal.pages) do 
			local label = string.format("  P%d  ##btn_page_%d", i, i)
			if imgui_utils.draw_btn(label, portal.cur_page == i) then 
				portal.set_page(i)
			end
			ImGui.SameLine()
		end
		ImGui.EndGroup()
		
		ImGui.SetCursorPos(0, line_y)
		ImGui.BeginChild("wnd_portal_content", size_x, size_y - line_y, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(8, 5)
		local list = portal.pages[portal.cur_page] or {}
		local wnd_files = editor.wnd_files
		ImGui.BeginGroup()
		for i, path in ipairs(list) do 
			local name = lib.get_file_name(path)
			local ext = lib.get_file_ext(path) or "folder"
			local id = wnd_files.get_icon_id_by_ext(ext) or 0
			ImGui.BeginGroup()
			local x, y = ImGui.GetCursorScreenPos()
			if i == hover_idx then 
				draw_list.AddRectFilled({min = {x, y}, max = {x + size_x - 20, y + line_y}, col = {0.25, 0.25, 0.25, 1}});                                    
			end
			ImGui.Image(dep.textureman.texture_get(id), 23, 23)
			ImGui.SameLineEx(45)
			if imgui_utils.draw_style_btn(name .. "##btn_none", imgui_styles.btn_transparency_left) then 
			end
			ImGui.SameLineEx(190)
			if imgui_utils.draw_btn(" 打 开 ##btn_portal_open_" .. i, true) then 
				if ext == "folder" then 
					editor.wnd_files.browse(path)
				else 
					editor.open_tab(path)
				end
			end
			ImGui.SameLine()
			if imgui_utils.draw_btn(" 选 中 ##btn_portal_browse_" .. i) then 
				editor.wnd_files.browse(path)
			end
			ImGui.EndGroup()
			if ImGui.IsItemHovered() then 
				if ImGui.IsMouseClicked(ImGui.MouseButton.Right) then 
					print("11")
				end
				hover_idx = i
			end
		end		
		ImGui.Dummy(10, 5)
		ImGui.EndGroup()
		ImGui.EndChild()
	end

	return api
end

return {new = new}