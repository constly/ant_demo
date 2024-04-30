---@type ly.game_editor.dep
local dep = require 'dep'
local common = dep.common
local imgui_styles = common.imgui_styles
local ImGui = dep.ImGui


---@param editor ly.map.renderer
local function new(editor)
	---@class ly.map.chess.ui_setting
	local api = {}
	local popId 
	local needOpen = false
	local input_content = ImGui.StringBuf()
	local isOpen = false
	local grid_def

	function api.open()
		popId = "地图配置##pop_chess_setting"
		needOpen = true
		grid_def = editor.data_hander.data.setting.grid_def or ""
	end

	function api.update()
		if needOpen then 
			ImGui.OpenPopup(popId)
			needOpen = false 
			isOpen = true
			local viewport = ImGui.GetMainViewport();
			local screen_x, screen_y = viewport.WorkSize.x, viewport.WorkSize.y
			local size_x, size_y = 500, 250
			ImGui.SetNextWindowSize(size_x, size_y)
			ImGui.SetNextWindowPos((screen_x - size_x) * 0.5, (screen_y - size_y) * 0.35)
		end
		if not isOpen then return end 

		local style<close> = imgui_styles.use(imgui_styles.popup)
		if ImGui.BeginPopupModal(popId, true, ImGui.WindowFlags({})) then 
			ImGui.NewLine()
			local x, y = ImGui.GetContentRegionAvail()
			do
				ImGui.SetCursorPos(20, 50)
				ImGui.Text("地图配置表")
				ImGui.SameLineEx(120)

				ImGui.PushItemWidth(300)
				input_content:Assgin(grid_def)
				local flag = ImGui.InputTextFlags { "CharsNoBlank", "AutoSelectAll" } 
				if ImGui.InputText("##input_box", input_content, flag) then 
					grid_def = tostring(input_content) or ""
				end
				ImGui.PopItemWidth()
			end
			do 
				ImGui.SetCursorPos(0, 120)
            	ImGui.Separator();
            	ImGui.SetCursorPos(x * 0.5 - 10, 160)
				if dep.common.imgui_utils.draw_btn(" 确 定 ##btn_setting_ok", true) then 
					ImGui.CloseCurrentPopup()
					isOpen = false
					if grid_def ~= editor.data_hander.data.setting.grid_def then 
						editor.data_hander.data.setting.grid_def = grid_def
						editor.refresh_object_def()
						editor.stack.snapshoot(true)
					end
				end
			end
			ImGui.EndPopup()
		else 
			isOpen = false
		end
	end

	return api
end

return {new = new}