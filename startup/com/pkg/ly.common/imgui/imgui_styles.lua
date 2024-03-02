local dep = require 'dep' ---@type ly.common.dep
local ImGui = dep.ImGui

---@class ly.common.imgui_styles
local api = {}
local styles = {}
api.type_btn_blue = 1

local register = function(type, on_push, on_pop)
	styles[type] = {on_push = on_push, on_pop}
end

local init = function()
	register(api.type_btn_blue, function()
		ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0, 1, 0, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0, 1, 0, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0, 1, 0, 1)
		ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.8, 0.8, 0.8, 1)
	end, function()
		ImGui.PopStyleColorEx(4)
	end)
end
init()

function api.push(type)
	local data = styles[type]
	if data then 
		data.on_push()
	end
end

function api.pop(type)
	local data = styles[type]
	if data then 
		data.on_pop()
	end
end

return api