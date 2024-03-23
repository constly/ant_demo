local dep = require 'dep' ---@type ly.common.dep
local ImGui = dep.ImGui

---@class ly.common.imgui_styles
local api = {}
local styles = {}
api.btn_blue = 1
api.btn_normal = 2
api.btn_transparency_center = 3
api.btn_transparency_center_selected = 4
api.btn_transparency_left = 5
api.btn_yellow = 6

api.btn_drop_hint = 50

api.popup = 100


local register = function(type, on_push, on_pop) 
	styles[type] = {on_push = on_push, on_pop = on_pop} 
end

local init = function()
	local function draw_btn(x, y, z, a)
		local scale = 1.1
		local x1, y1, z1, a1 = x * scale, y * scale, z * scale, a * scale
		ImGui.PushStyleColorImVec4(ImGui.Col.Button, x, y, z, a)
		ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, x1, y1, z1, a1)
		ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, x1, y1, z1, a1)
	end
	register(api.btn_blue, function()
		ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.16, 0.4, 0.51, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.484, 0.61, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.3, 0.484, 0.61, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.9, 0.9, 0.9, 1)
	end, function()
		ImGui.PopStyleColorEx(4)
	end)

	register(api.btn_yellow, function()
		draw_btn(0.5, 0.5, 0, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.9, 0.9, 0.9, 1)
	end, function()
		ImGui.PopStyleColorEx(4)
	end)

	register(api.btn_normal, function()
		draw_btn(0.3, 0.3, 0.25, 1)
	end, function()
		ImGui.PopStyleColorEx(3)
	end)

	register(api.btn_transparency_center, function()
		draw_btn(0, 0, 0, 0);
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0.5, 0.5)
		ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.8, 0.8, 0.8, 1)
	end, function()
		ImGui.PopStyleColorEx(4)
		ImGui.PopStyleVarEx(1)
	end)

	register(api.btn_transparency_center_selected, function()
		draw_btn(0, 0, 0, 0);
		ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0, 0.8, 0.8, 1)
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0.5, 0.5)
	end, function()
		ImGui.PopStyleColorEx(4)
		ImGui.PopStyleVarEx(1)
	end)

	register(api.btn_transparency_left, function()
		draw_btn(0, 0, 0, 0);
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
		ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.8, 0.8, 0.8, 1)
	end, function()
		ImGui.PopStyleColorEx(4)
		ImGui.PopStyleVarEx(1)
	end)

	register(api.btn_drop_hint, function()
		draw_btn(0, 0.8, 0.8, 0.5);
	end, function()
		ImGui.PopStyleColorEx(3)
	end)
	
	register(api.popup, function()
		ImGui.PushStyleColorImVec4(ImGui.Col.ModalWindowDimBg, 0.5, 0.5, 0.5, 0.35)
		ImGui.PushStyleColorImVec4(ImGui.Col.WindowBg, 0.15, 0.15, 0.15, 1)
	end, function()
		ImGui.PopStyleColorEx(2)
	end)
end
init()

function api.push(type)
	local data = styles[type]
	if data then data.on_push() end
end

function api.pop(type)
	local data = styles[type]
	if data then data.on_pop() end
end

function api.use(type)
	api.push(type)
	return setmetatable({}, {__close = function() api.pop(type) end})
end

return api