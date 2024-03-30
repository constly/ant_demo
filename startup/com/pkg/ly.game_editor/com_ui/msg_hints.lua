--------------------------------------------------------
-- 通用 消息提示框
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local common = dep.common
local ImGuiExtend = dep.ImGuiExtend

---@class ly.game_editor.msg_hints.type 
---@field Info number
---@field OK number
---@field Warnning number 
---@field Error number
local tb_hint_type


---@class ly.game_editor.msg_hints.msg_data 
---@field time number 
---@field msg string 
---@field offset number
---@field delay number
---@field posY number
---@field wait number
---@field alphaWait number
---@field type ly.game_editor.msg_hints.type 
---@field color number[] 颜色
local tb_msg_data = {}

---@return ly.game_editor.msg_hints
---@param editor ly.game_editor.editor
local function create(editor)
	local api = {} 			---@class ly.game_editor.msg_hints
	local tb_msg = {}		---@type ly.game_editor.msg_hints.msg_data[]
	local delay = 0;
	local colorError<const> = {0.9, 0, 0, 1}
	local colorWarning<const> = {0.9, 0.9, 0, 1}
	local colorInfo<const> = {0.9, 0.9, 0.9, 1}
	local colorOK<const> = {0, 0.9, 0, 1}

	---@param msg string 
	---@param type ly.game_editor.msg_hints.type info|ok|warning|error
	function api.show(msg, type)
		---@type ly.game_editor.msg_hints.msg_data 
		local tb = {}
		tb.msg = msg
		tb.time = 3 
		tb.type = type
		tb.offset = 200
		tb.delay = delay
		tb.posY = 80
		tb.wait = 1
		tb.alphaWait = 1
		delay = delay + 1

		local color = colorInfo
		if type == "info" 	then color = colorInfo
		elseif type == "ok" then color = colorOK
		elseif type == 'warning' then color = colorWarning
		elseif type == "error" then color = colorError end
		tb.color = common.lib.copy(color)
		table.insert(tb_msg, 1, tb)
	end

	function api.clear()
		tb_msg = {}
		delay = 0
	end

	function api.update(deltaTime)
		local screen_x, screen_y = editor.style.get_display_size()
		local start_x = screen_x * 0.5 - 100
		delay = 0
		for i = #tb_msg, 1, -1 do 
			local one = tb_msg[i]
			one.delay = one.delay - deltaTime
			if one.delay <= 0 then
				if one.wait > 0 then 
					one.wait = one.wait - deltaTime
				else
					one.posY = one.posY - 100 * deltaTime
				end
				one.alphaWait = one.alphaWait - deltaTime
				one.time = one.time - deltaTime
				--ImGui.SetCursorPos(start_x, one.posY)
				if one.alphaWait < 0 then
					one.color[4] = 1 + one.alphaWait
				end

				ImGuiExtend.draw_list.AddText({
					pos = {start_x, one.posY},
					col = one.color,
					text = one.msg,
					type = "foreground",
				})
				if one.time <= 0 or one.posY < -50 then 
					table.remove(tb_msg, i)
				end
			end
		end
	end

	return api	
end

return {create = create}