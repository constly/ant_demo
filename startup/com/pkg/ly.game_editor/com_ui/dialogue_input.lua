--------------------------------------------------------
-- 通用 输入框
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local common = dep.common
local imgui_styles = common.imgui_styles
local ImGui = dep.ImGui

---@class ly.game_editor.dialogue_input.open_param
---@field title string 标题
---@field header string 条目
---@field value string 内容
---@field isFileName boolean 是不是文件名（输入时只能输入特定字符）
---@field onCancel function 取消回调 
---@field onOK function 成功回调
local open_param

---@param editor ly.game_editor.editor
---@return ly.game_editor.dialogue_input
local function create(editor)
	local api = {} 			---@class ly.game_editor.dialogue_input
	local open_param 		---@type ly.game_editor.dialogue_input.open_param
	local isOpen = false	---@type boolean 是否打开
	local popId = ""		---@type string 
	local needOpen = false  ---@type boolean
	local input_content = ImGui.StringBuf()

	---@param param ly.game_editor.dialogue_input.open_param
	function api.open(param)
		open_param = param
		open_param.value = open_param.value or ""
		popId = param.title .. "##pop_id_dialogue_input"
		needOpen = true
		input_content:Assgin(param.value or "")
	end

	function api.update()
		if needOpen then 
			ImGui.OpenPopup(popId)
			needOpen = false 
			isOpen = true
			local screen_x, screen_y = editor.style.get_display_size()
			local size_x, size_y = 400, 250
			ImGui.SetNextWindowSize(size_x, size_y)
			ImGui.SetNextWindowPos((screen_x - size_x) * 0.5, (screen_y - size_y) * 0.35)
		end
		if not isOpen then return end 

		local style<close> = imgui_styles.use(imgui_styles.popup)
		if ImGui.BeginPopupModal(popId, true, ImGui.WindowFlags({})) then 
			ImGui.NewLine()
			local x, y = ImGui.GetContentRegionAvail()
			do
				ImGui.SetCursorPos(50, 50)
				ImGui.Text(open_param.header)
				ImGui.SameLineEx(150)

				ImGui.PushItemWidth(150)
				if ImGui.InputText("##input_box", input_content) then 
					open_param.value = tostring(input_content) or ""
				end
				ImGui.PopItemWidth()
			end
			do 
				ImGui.SetCursorPos(0, 120)
            	ImGui.Separator();
            	ImGui.SetCursorPos(x * 0.5 - 60, 160)
				if editor.style.draw_btn(" 取 消 ##btn_cancel_msg_box") then 
					ImGui.CloseCurrentPopup()
					isOpen = false
					if open_param.onCancel then open_param.onCancel() end 
				end
				ImGui.SameLineEx(x * 0.5 + 10)
				if editor.style.draw_btn(" 确 认  ##btn_confirm_msg_box", true) and #open_param.value > 0 then 
					local state = true
					local value = open_param.value
					if open_param.isFileName then 
						if string.match(value, "^[^%c%z\\/:*?\"<>|]+$") == nil then 
							state = false
						end
					end
					if state then 
						ImGui.CloseCurrentPopup()
						isOpen = false
						if open_param.onOK then 
							open_param.onOK(value, open_param)
						end
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