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

--- 绘制按钮
---@param label string 
---@param selected boolean 是否选中
---@param tbParams table 扩展参数{size_x = 100, size_y = 100}
function api.draw_btn(label, selected, tbParams)
	if selected then 
		ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.6, 0.6, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.5, 0.5, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.5, 0.5, 0.25, 1)
	else  
		ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
	end

	tbParams = tbParams or {}
	local ok = false
	if ImGui.ButtonEx(label, tbParams.size_x, tbParams.size_y) then 
		ok = true;
	end

	ImGui.PopStyleColorEx(3)
	return ok;
end

return api;