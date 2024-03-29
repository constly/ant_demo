local dep = require 'dep'
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

	local height_title = 30
	local height_bottom = 200
	local bottom_header_y = 30
	local size_portal_x = 400  --- 传送门
	local size_x, size_y
	
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

	local function draw_bottom()
		ImGui.SetCursorPos(0, size_y - height_bottom)
		ImGui.BeginChild("wnd_bottom", size_x, height_bottom, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(5, 3)
			ImGui.Button("文件")
			ImGui.SameLine()
			ImGui.Button("日志")
			
			ImGui.SetCursorPos(0, bottom_header_y)
			ImGui.BeginChild("wnd_bottom_1", size_x - size_portal_x, height_bottom - bottom_header_y, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(5, 3)
			ImGui.Text("文件列表/日志")
			ImGui.EndChild()

			ImGui.SetCursorPos(size_x - size_portal_x, 0)
			ImGui.BeginChild("wnd_portal", size_portal_x, height_bottom, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(5, 3)
			ImGui.Button("传送门")
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
	end
	return api
end




return {create = create}