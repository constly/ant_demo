--------------------------------------------------------
-- 窗口 日志列表
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ImGui = dep.ImGui

local function new()
	---@class ly.game_editor.wnd_log
	local api = {}

	function api.draw(deltatime)
		ImGui.Text("日志列表")
	end

	return api
end

return {new = new}