local dep = require 'dep' ---@type ly.common.dep
local ImGui = dep.ImGui

---@class ly.common.imgui_utils
local api = {}

--- 中间居中绘制文本
function api.draw_text_center(text)
	local size_x, _ = ImGui.GetContentRegionAvail()
	local len = ImGui.CalcTextSize(text)
	ImGui.Dummy((size_x - len) * 0.5 - 15, 20)
	ImGui.SameLine()
	ImGui.Text(text)
end

return api;