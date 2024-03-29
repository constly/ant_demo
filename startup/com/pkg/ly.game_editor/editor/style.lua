--------------------------------------------------------
-- 编辑器风格样式定义
--------------------------------------------------------
---@class ly.game_editor.style 风格定义
style = {}
style.btn_normal = "normal"

style.cell_body = "cell_body"
style.cell_body_active = "cell_body_active"
style.cell_head = "cell_head"
style.cell_head_active = "cell_head_active"




--------------------------------------------------------
-- 风格样式注册
--------------------------------------------------------
---@class ly.game_editor.style.all 
---@field name string 大类别
---@field list ly.game_editor.style.all_item[]

---@class ly.game_editor.style.all_item 
---@field name string 样式名字
---@field type string 样式类型
---@field desc string 样式描述

local types = {}
types.button = "button"
types.cell = "cell"
types.text = "text"
types.popup = "popup"


local function get_styles()
	---@type ly.game_editor.style.all[] 
	local all = {}
	local function reg(category, name, type, desc)
		local tb
		for i, v in ipairs(all) do 
			if v.name == category then 
				tb = v 
				break
			end
		end
		if not tb then 
			tb = {name = category, list = {}}
			table.insert(all, tb)
		end
		table.insert(tb.list, {name = name, type = type, desc = desc})
	end

	reg("表 格", style.cell_body, 					types.cell, "表格内容")
	reg("表 格", style.cell_body_active, 			types.cell, "表格内容激活")
	reg("表 格", style.cell_head, 					types.cell, "表头")
	reg("表 格", style.cell_head_active, 			types.cell, "表头激活")

	return all
end

--------------------------------------------------------
-- 编辑器风格绘制
--------------------------------------------------------
local function new()
	local dep = require 'dep' ---@type ly.game_editor.dep
	local ImGui = dep.ImGui

	---@class ly.game_editor.style.draw  --- 使用
	local api = {}
	api.styles = {}

	local types_cb = {}
	local function init_callbacks()
		local register = function(type, on_push, on_pop) 
			api.styles[type] = {on_push = on_push, on_pop = on_pop} 
		end

		types_cb[types.button] = function(data)
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

		types_cb[types.text] = function(data)
			register(data.type, function()
				ImGui.PushStyleColorImVec4(ImGui.Col.Text, table.unpack(data.text))
			end, function()
				ImGui.PopStyleColorEx(1)
			end)
		end 
		
		types_cb[types.cell] = function(data)
		
		end 

		types_cb[types.popup] = function(data)
			register(data.type, function()
				ImGui.PushStyleColorImVec4(ImGui.Col.ModalWindowDimBg, table.unpack(data.dimbg))
				ImGui.PushStyleColorImVec4(ImGui.Col.WindowBg, table.unpack(data.bg))
			end, function()
				ImGui.PopStyleColorEx(2)
			end)
		end
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
			local cb = types_cb[v.type]
			if cb then 
				cb(v)
			else 
				log.warn("invalid style type: " .. (v.type or ""))
			end
		end
	end

	function api.draw_btn_with_style(style_name)

	end

	function api.draw_text_with_style(style_name)
	end

	init_callbacks()
	api.set_theme()
	return api
end

return {new = new, get_styles = get_styles}