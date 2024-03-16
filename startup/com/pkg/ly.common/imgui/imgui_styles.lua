local dep = require 'dep' ---@type ly.common.dep
local ImGui = dep.ImGui

---@class ly.common.imgui_styles
local api = {}
local styles = {}
api.btn_blue = 1
api.btn_normal = 2
api.popup = 3


local register = function(type, on_push, on_pop) 
	styles[type] = {on_push = on_push, on_pop = on_pop} 
end
local init = function()
	register(api.btn_blue, function()
		ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.16, 0.484, 0.81, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.484, 0.81, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.3, 0.484, 0.81, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.9, 0.9, 0.9, 1)
	end, function()
		ImGui.PopStyleColorEx(4)
	end)

	register(api.btn_normal, function()
		ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
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