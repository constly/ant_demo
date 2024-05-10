---@param client sims.client
---@return sims.client.editor
local function new(client)
	local ImGui 		= require "imgui"
	---@type ly.common
	local common 		= import_package 'ly.common' 	
	---@type ly.game_editor	
	local game_editor  	= import_package 'ly.game_editor'
	---@type ly.game_editor.editor
	local editor  
	local expand = false

	local refresh_window = true
	local window_pos_dirty = true
	local is_fullscreen = false
	local window_flag

	local refresh_type = 1
	local refresh_def = {
		{name = "存档/读档", type = "save_and_load"},
		{name = "新建存档", type = "new_save"},
	}
	local custom_window_size = {}

	---@class sims.client.editor
	local api = {}

	local function set_expand(v)
		expand = v
		refresh_window = true;
		common.user_data.set("sims.expand", expand and 1 or 0, true)
	end

	local function notify_refresh()
		if editor then
			editor.wnd_mgr.notify_auto_save()
		end
		client.call_server(client.msg.rpc_restart, {type = refresh_def[refresh_type].type})
	end


	function api.init()
		local fonts = {}
		fonts[#fonts+1] = {
			FontPath = "/pkg/ant.resources.binary/font/Alibaba-PuHuiTi-Regular.ttf",
			--FontPath = "/pkg/sims.res/assets/font/WenQuanDengKuanWeiMiHei.ttf",
			SizePixels = 18,
			GlyphRanges = { 0x0020, 0xFFFF }
		}
		local ImGuiAnt  = import_package "ant.imgui"
		ImGuiAnt.FontAtlasBuild(fonts)	
		expand = tonumber(common.user_data.get("sims.expand")) == 1
		is_fullscreen = tonumber(common.user_data.get("sims.fullscreen")) == 1
		refresh_type = tonumber(common.user_data.get("sims.refresh_type")) or 1
		if not refresh_def[refresh_type] then 
			refresh_type = 1
		end

		local arr = common.lib.split(common.user_data.get("sims.custom_size", "0,0.01,0.5,0.98"), ",")
		custom_window_size = {
			math.max(0.01, tonumber(arr[1]) or 0), 
			math.max(0.01, tonumber(arr[2]) or 0.01), 
			math.min(0.98, tonumber(arr[3]) or 0.98), 
			math.min(0.99, tonumber(arr[4]) or 0.98),
		}
	end 

	function api.exit()
		if editor then 
			editor.exit()
			editor = nil
		end
		if custom_window_size[1] then
			common.user_data.set("sims.custom_size", string.format("%f,%f,%f,%f", table.unpack(custom_window_size)), true)
		end
	end

	function api.update()
		local dpi = ImGui.GetMainViewport().DpiScale
		local viewport = ImGui.GetMainViewport();
		local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
		if refresh_window then 
			refresh_window = false
			local top_x, top_y, width, height = 0, 0, size_x, size_y
			if not is_fullscreen then 
				local x, y, w, h = table.unpack(custom_window_size)
				top_x, top_y = size_x * x, size_y * y
				width, height = size_x * w, size_y * h
			end
			if not expand then
				width, height = 170 * dpi, 40 * dpi
			end
			if window_pos_dirty then 
				window_pos_dirty = false
				ImGui.SetNextWindowPos(top_x, top_y)
			end
			ImGui.SetNextWindowSize(width, height);
			if is_fullscreen then 
				window_flag = ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}
			else 
				window_flag = ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}
			end
		end
		
		if ImGui.Begin("window_body", nil, window_flag) then 
			local width, height = ImGui.GetWindowSize()
			if expand and not is_fullscreen and size_x > 0 then
				local pos_x, pos_y = ImGui.GetWindowPos()
				custom_window_size = {pos_x / size_x, pos_y / size_y, width / size_x, height / size_y}
			end

			if common.imgui_utils.draw_btn(" 主 页 ", not expand) then 
				if expand then 
					set_expand(not expand)
				else 
					client.statemachine.goto_state(client.statemachine.state_entry)
				end
			end
			ImGui.SameLine()
			if common.imgui_utils.draw_btn("编辑器", expand) then 
				set_expand(not expand)
			end
			
			ImGui.SameLineEx(math.max(120 * dpi, width - 250))
			if common.imgui_utils.draw_btn(" 刷 新 ", true) then 
				notify_refresh()
			end
			ImGui.SameLine()
			ImGui.SetNextItemWidth(120 * dpi)
			if ImGui.BeginCombo("##combo", refresh_def[refresh_type].name) then
				for i, one in ipairs(refresh_def) do
					if ImGui.Selectable(one.name, i == refresh_type) then
						refresh_type = i
						common.user_data.set("sims.refresh_type", i, true)
					end
				end
				ImGui.EndCombo()
			end
			ImGui.SameLine()
			if common.imgui_utils.draw_btn(" 全 屏 ", is_fullscreen) then 
				is_fullscreen = not is_fullscreen
				refresh_window = true;
				window_pos_dirty = true
				common.user_data.set("sims.fullscreen", is_fullscreen and 1 or 0, true)
			end
			
			if expand then 
				if not editor then 
					---@type ly.game_editor.create_params
					local tbParams = {}
					tbParams.module_name = "sims"
					tbParams.project_root = common.path_def.project_root
					tbParams.pkgs = {"sims.res"}
					tbParams.theme_path = "sims.res/themes/default.style"
					tbParams.workspace_path = "/pkg/sims.res/space.work"
					tbParams.goap_mgr = require 'goap.goap'
					tbParams.menus = {
						{name = "存档助手", window = require 'editor.wnd_saved'.new(client) },
						{name = "开发计划", window = require 'editor.wnd_dev_plan'.new(client) },
						{name = "调试面板", window = require 'editor.wnd_debug'.new(client) },
					}
					editor = game_editor.create_editor(tbParams)
				end
				local x, y = ImGui.GetContentRegionAvail()
				ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 0, 0)
				ImGui.BeginChild("ImGui.BeginChild", x, y, ImGui.ChildFlags({"Border"}))
				editor.draw()
				ImGui.EndChild()
				ImGui.PopStyleVar()
			end
		end 
		ImGui.End()
	end

	return api
end

return {new = new}