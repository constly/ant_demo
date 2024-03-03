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

--- 绘制按钮
---@param label string 
---@param bg_color number[] 背景颜色
---@param txt_clor number[] 背景颜色
---@param tbParams table 扩展参数{size_x = 100, size_y = 100}
function api.draw_color_btn(label, bg_color, txt_clor, tbParams)
	local hover_color = {bg_color[1] * 1.12, bg_color[2] * 1.12, bg_color[3] * 1.12, bg_color[4] * 1.12}
	ImGui.PushStyleColorImVec4(ImGui.Col.Button, table.unpack(bg_color))
	ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, table.unpack(hover_color))
	ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, table.unpack(hover_color))
	ImGui.PushStyleColorImVec4(ImGui.Col.Text, table.unpack(txt_clor))
	local ok = false
	tbParams = tbParams or {}
	if ImGui.ButtonEx(label, tbParams.size_x, tbParams.size_y) then ok = true end
	ImGui.PopStyleColorEx(4)
	return ok
end

return api;