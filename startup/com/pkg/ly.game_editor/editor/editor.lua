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
	api.files = (require 'com_data.files').new(api)
	api.portal = (require 'com_data.portal').new(api)
	api.workspaces = (require 'com_data.workspaces').new(api)

	api.wnd_files = (require 'editor.widgets.wnd_files').new(api)
	api.wnd_space = (require 'editor.widgets.wnd_space').new(api)
	api.wnd_log = (require 'editor.widgets.wnd_log').new(api)
	api.wnd_portal = (require 'editor.widgets.wnd_portal').new(api)

	--local height_title = 30 
	local height_bottom = 200
	local is_buttom_collapse = false
	local size_portal_x = 300  --- 传送门
	local size_x, size_y
	local show_type = 1
	local line_y = 30

	local function draw_viewports(deltatime)
		local height = is_buttom_collapse and (size_y - line_y) or (size_y - height_bottom) 
		ImGui.BeginChild("panel_viewports", size_x, height, ImGui.ChildFlags({"Border"}))
		ImGui.SetCursorPos(5, 0)
		ImGui.BeginGroup()
		ImGui.Dummy(0, 0)
		local cur = api.workspaces.current_space()
		for i, space in ipairs(api.workspaces.works) do 
			if imgui_utils.draw_btn(string.format("Space%02d", i), space == cur)	then 
				api.workspaces.set_current_space(i)
			end
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
			if ImGui.BeginPopupContextItem() then 
				api.workspaces.set_current_space(i)
				if ImGui.MenuItem("关闭") then 
					api.workspaces.close_self(i, space)
				end
				if ImGui.MenuItem("关闭其他") then 
					api.workspaces.close_others(i, space)
				end
				ImGui.EndPopup()
			end
			ImGui.PopStyleVar()
		end
		local x, y = ImGui.GetItemRectSize();
		line_y = y + 4
		if #api.workspaces.works < 15 and imgui_utils.draw_btn(" + ##btn_add_workspace" , false, {size_x = x})	then 
			api.workspaces.add()
		end
		ImGui.EndGroup()

		ImGui.SameLine()

		local x, y = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("panel_viewports_body", x, y, ImGui.ChildFlags({"Border"}))
			api.wnd_space.draw(deltatime, line_y)
		ImGui.EndChild()

		ImGui.EndChild()
	end

	local function draw_bottom(deltatime)
		if is_buttom_collapse then 
			ImGui.SetCursorPos(size_x - 70, size_y - line_y + 1.5)
			if imgui_utils.draw_btn(" ↑↑ ") then 
				is_buttom_collapse = false
			end
			return 
		end
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
			local x, y = ImGui.GetContentRegionAvail()
			ImGui.BeginChild("wnd_bottom_1", size_x - size_portal_x, y, ImGui.ChildFlags({"Border"}))
			if show_type == 1 then api.wnd_files.draw(deltatime, line_y) 
			elseif show_type == 2 then api.wnd_log.draw(deltatime, line_y) end
			ImGui.EndChild()

			ImGui.SetCursorPos(size_x - size_portal_x, 0)
			ImGui.BeginChild("wnd_portal", size_portal_x, height_bottom, ImGui.ChildFlags({"Border"}))
			ImGui.SetCursorPos(5, 3)
			imgui_utils.draw_btn(" 收 藏 ", true)
			ImGui.SetCursorPos(size_portal_x - 70, 3)
			if imgui_utils.draw_btn(" ↓↓ ", false) then 
				is_buttom_collapse = true
			end
				local x, y = ImGui.GetContentRegionAvail()
				ImGui.BeginChild("wnd_portal_1", size_portal_x, y, ImGui.ChildFlags({"Border"}))
				api.wnd_portal.draw(deltatime, line_y)
				ImGui.EndChild()
			ImGui.EndChild()
		ImGui.EndChild()
	end

	function api.exit()
		api.workspaces.exit()
	end

	function api.draw()
		size_x, size_y = ImGui.GetContentRegionAvail()
		-- draw_title()
		-- draw_middle()
		draw_viewports()
		draw_bottom()

		api.dialogue_input.update()
		api.dialogue_msgbox.update()
		api.msg_hints.update(0.04)
	end

	function api.open_tab(path)
		local space = api.workspaces.current_space()
		local viewport = space and space.get_active_viewport()
		if viewport then 
			viewport.tabs.open_tab(path)
		end
	end
	return api
end




return {create = create}