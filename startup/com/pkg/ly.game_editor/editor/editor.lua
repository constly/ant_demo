---@type ly.game_editor.dep
local dep = require 'dep'
local imgui_utils = dep.common.imgui_utils
local ImGui = dep.ImGui

---@param tbParams ly.game_editor.create_params
local function create(tbParams)
	---@class ly.game_editor.editor
	local api = {}
	api.tbParams = tbParams
	api.dialogue_input = (require 'com_ui.dialogue_input').create()  	
	api.dialogue_msgbox = (require 'com_ui.dialogue_msgbox').create()
	api.msg_hints = (require 'com_ui.msg_hints').create()
	api.i18n = (require 'com_data.i18n').create()
	api.files = (require 'com_data.files').create(api)

	api.wnd_files = (require 'editor.widgets.wnd_files').create(api)
	api.wnd_log = (require 'editor.widgets.wnd_log').create(api)
	api.wnd_portal = (require 'editor.widgets.wnd_portal').create(api)

	local height_title = 30
	local height_bottom = 200
	local bottom_header_y = 30
	local size_portal_x = 400  --- 传送门
	local size_x, size_y
	local show_type = 1

	local function draw_title()
		--ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
        ImGui.BeginChild("panel_window_title", size_x, height_title, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(5, 3)
		ImGui.BeginGroup()
		ImGui.Button("config.ini")
		ImGui.SameLine()
		ImGui.Button("map_01.map")
		ImGui.EndGroup()
		ImGui.EndChild()
		--ImGui.PopStyleVar()
	end

	local function draw_middle()
		ImGui.SetCursorPos(0, height_title)
		ImGui.BeginChild("panel_window_middle", size_x, size_y - height_bottom - height_title, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(5, 3)
		ImGui.Text("各种编辑器绘制")
		ImGui.EndChild()
	end

	local function draw_bottom(deltatime)
		ImGui.SetCursorPos(0, size_y - height_bottom)
		ImGui.BeginChild("wnd_bottom", size_x, height_bottom, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(5, 3)
			if imgui_utils.draw_btn(" 文 件 ", show_type == 1) then 
				show_type = 1
			end
			ImGui.SameLine()
			if imgui_utils.draw_btn(" 日 志 ", show_type == 2) then 
				show_type = 2
			end
			ImGui.SameLineEx(size_x - size_portal_x - 70)
			if imgui_utils.draw_btn(" 查 找 ") then 
				
			end

			ImGui.SetCursorPos(0, bottom_header_y)
			ImGui.BeginChild("wnd_bottom_1", size_x - size_portal_x, height_bottom - bottom_header_y, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(5, 3)
			if show_type == 1 then api.wnd_files.draw(deltatime) 
			elseif show_type == 2 then api.wnd_log.draw(deltatime) end
			ImGui.EndChild()

			ImGui.SetCursorPos(size_x - size_portal_x, 0)
			ImGui.BeginChild("wnd_portal", size_portal_x, height_bottom, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(5, 3)
			imgui_utils.draw_btn(" 收 藏 ", true)
				ImGui.SetCursorPos(0, bottom_header_y)
				ImGui.BeginChild("wnd_portal_1", size_portal_x, height_bottom - bottom_header_y, ImGui.ChildFlags({"Border"}))
				ImGui.SetCursorPos(5, 3)
				ImGui.Text("传送门文件列表")
				ImGui.EndChild()
			ImGui.EndChild()
		ImGui.EndChild()
	end

	function api.draw()
		size_x, size_y = ImGui.GetContentRegionAvail()
		draw_title()
		draw_middle()
		draw_bottom()

		api.dialogue_input.update()
		api.dialogue_msgbox.update()
		api.msg_hints.update(0.04)
	end
	return api
end




return {create = create}