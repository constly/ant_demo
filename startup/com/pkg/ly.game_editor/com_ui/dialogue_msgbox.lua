--------------------------------------------------------
-- 通用 消息弹出确认框
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local common = dep.common
local imgui_styles = common.imgui_styles
local imgui_utils = common.imgui_utils
local ImGui = dep.ImGui

---@class ly.game_editor.dialogue_msgbox.open_param
---@field title string 标题
---@field msg string 内容
---@field onCancel function 取消回调 
---@field onOK function 成功回调
local open_param


---@return ly.game_editor.dialogue_msgbox
local function create()
	local api = {} ---@class ly.game_editor.dialogue_msgbox
	local open_param 		---@type ly.game_editor.dialogue_msgbox.open_param
	local isOpen = false	---@type boolean 是否打开
	local popId = ""		---@type string 
	local needOpen = false  ---@type boolean
	local msg = ""

	---@param param ly.game_editor.dialogue_msgbox.open_param
	function api.open(param)
		open_param = param
		popId = param.title .. "##pop_id_dialogue_msgbox"
		msg = "\t\t" .. open_param.msg;
		needOpen = true
	end

	function api.update()
		if needOpen then 
			ImGui.OpenPopup(popId)
			needOpen = false 
			isOpen = true
			local screen_x, screen_y = imgui_utils.get_display_size()
			local size_x, size_y = 400, 220
			ImGui.SetNextWindowSize(size_x, size_y)
			ImGui.SetNextWindowPos((screen_x - size_x) * 0.5, (screen_y - size_y) * 0.35)
		end
		if not isOpen then return end 

		local style<close> = imgui_styles.use(imgui_styles.popup)
		if ImGui.BeginPopupModal(popId, true, ImGui.WindowFlags({})) then 
			local x, y = ImGui.GetContentRegionAvail()
			ImGui.NewLine()
			ImGui.Dummy(30, 20)
			ImGui.SameLine()
			ImGui.PushTextWrapPos(x - 50)
			ImGui.Text(msg)
			ImGui.PopTextWrapPos()

			do 
				ImGui.SetCursorPos(0, 130)
            	ImGui.Separator();
            	ImGui.SetCursorPos(x * 0.5 - 60, 160)
				if imgui_utils.draw_btn(" 取 消 ##btn_cancel_msg_box") then 
					ImGui.CloseCurrentPopup()
					isOpen = false
					if open_param.onCancel then open_param.onCancel() end 
				end
				ImGui.SameLineEx(x * 0.5 + 10)
				if imgui_utils.draw_btn(" 确 认  ##btn_confirm_msg_box", true) then 
					ImGui.CloseCurrentPopup()
					isOpen = false
					if open_param.onOK then 
						open_param.onOK(open_param)
					end
				end
			end

			ImGui.EndPopup()
		else 
			if open_param.onCancel then 
				open_param.onCancel()
			end
			isOpen = false
		end
	end
	
	return api	
end

return {create = create}