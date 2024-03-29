--------------------------------------------------------
-- 编辑器风格样式定义
--------------------------------------------------------
---@class ly.game_editor.style 风格定义
style = {}
style.btn_normal = "normal"





--------------------------------------------------------
-- 编辑器风格绘制
--------------------------------------------------------
local function new()
	local dep = require 'dep' ---@type ly.game_editor.dep
	local ImGui = dep.ImGui

	---@class ly.game_editor.style.draw  --- 使用
	local api = {}
	api.styles = {}
	
	local register = function(type, on_push, on_pop) 
		api.styles[type] = {on_push = on_push, on_pop = on_pop} 
	end

	local function reg_button(data)
		register(data.type, function()
			ImGui.PushStyleColorImVec4(ImGui.Col.Button, table.unpack(data.normal))
			ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, table.unpack(data.hovered))
			ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, table.unpack(data.active))
			ImGui.PushStyleColorImVec4(ImGui.Col.Text, table.unpack(data.text))
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, table.unpack(data.align))
		end, function()
			ImGui.PopStyleColorEx(4)
			ImGui.PopStyleVarEx(1)
		end)
	end

	local function reg_cell(data)
		
	end

	local function reg_popup(data)
		register(data.type, function()
			ImGui.PushStyleColorImVec4(ImGui.Col.ModalWindowDimBg, table.unpack(data.dimbg))
			ImGui.PushStyleColorImVec4(ImGui.Col.WindowBg, table.unpack(data.bg))
		end, function()
			ImGui.PopStyleColorEx(2)
		end)
	end

	local function reg_text(data)
		register(data.type, function()
			ImGui.PushStyleColorImVec4(ImGui.Col.Text, table.unpack(data.text))
		end, function()
			ImGui.PopStyleColorEx(1)
		end)
	end

	local function push(type)
		local data = api.styles[type]
		if data then data.on_push() end
	end
	
	local function pop(type)
		local data = api.styles[type]
		if data then data.on_pop() end
	end

	function api.use(style_name)
		push(style_name)
		return setmetatable({}, {__close = function() pop(style_name) end})
	end 

	--- 设置主题
	function api.set_theme(name)
		api.styles = {}
		local tb_data = {}
		for i, v in pairs(tb_data) do 
			if v.type == "button" then reg_button(v)
			elseif v.type == "cell" then reg_cell(v) 
			elseif v.type == "text" then reg_text(v)
			elseif v.type == "popup" then reg_popup(v)
			else log.warn("invalid style type: " .. (v.type or "")) end
		end
	end

	function api.draw_btn_with_style(style_name)

	end

	function api.draw_text_with_style(style_name)
	end

	api.set_theme()
	return api
end

return {new = new}