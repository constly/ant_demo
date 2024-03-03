local dep = require 'dep' ---@type ly.common.dep
local ImGui = dep.ImGui
local style = require 'imgui.imgui_styles'  ---@type ly.common.imgui_styles

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
	local use<close> = style.use(selected and style.btn_blue or style.btn_normal)
	tbParams = tbParams or {}
	return ImGui.ButtonEx(label, tbParams.size_x, tbParams.size_y)
end

--- 绘制按钮
---@param label string 
---@param style_type ly.common.imgui_styles
---@param tbParams table 扩展参数{size_x = 100, size_y = 100}
function api.draw_style_btn(label, style_type, tbParams)
	local use<close> = style.use(style_type)
	tbParams = tbParams or {}
	return ImGui.ButtonEx(label, tbParams.size_x, tbParams.size_y) 
end

return api;