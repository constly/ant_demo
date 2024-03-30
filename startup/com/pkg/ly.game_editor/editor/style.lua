local dep = require 'dep' ---@type ly.game_editor.dep
local ImGui = dep.ImGui

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

	reg("表 格", style.cell_body, 					types.button, 	"表格内容")
	reg("表 格", style.cell_body_active, 			types.button, 	"表格内容激活")
	reg("表 格", style.cell_head, 					types.button, 	"表头")
	reg("表 格", style.cell_head_active, 			types.button, 	"表头激活")

	reg("常 用", "test1", 			types.button, 	"测试1")
	reg("常 用", "test2", 			types.button, 	"测试2")

	return all
end


local function get_attrs()
	local tb_attrs = {}
	tb_attrs[types.button] = {
		-- 类型	变量名	变量说明	imgui枚举	默认值
		{"col", 		"normal", 		"正常显示状态", 	ImGui.Col.Button, 				{0.2, 0.2, 0.2, 1}},
		{"col", 		"hovered", 		"鼠标悬停状态", 	ImGui.Col.ButtonHovered,		{0.35, 0.35, 0.3, 1}},
		{"col", 		"active", 		"激活状态", 		ImGui.Col.ButtonActive, 		{0.3, 0.3, 0.3, 1}},
		{"col", 		"text", 		"文本颜色", 		ImGui.Col.Text,					{0.8, 0.8, 0.8, 1}},
		{"style_var", 	"text_align", 	"文本对齐", 		ImGui.StyleVar.ButtonTextAlign, {0.5, 0.5}},
	}

	tb_attrs[types.text]	= {
		{"col", 		"text", 		"文本颜色", 		ImGui.Col.Text,					{0.9, 0.9, 0.9, 1}},
	}

	tb_attrs[types.popup]	= {
		{"col", 		"dimbg", 		"弹框背景", 		ImGui.Col.ModalWindowDimBg,		{0.1, 0.1, 0.1, 1}},
		{"col", 		"bg", 			"窗口背景色", 		ImGui.Col.WindowBg,				{0.5, 0.5, 0.5, 0.5}},
	}

	tb_attrs[types.cell]	= {
		{"col", 		"text", 		"文本颜色", 		ImGui.Col.Text,					{0.9, 0.9, 0.9, 1}},
	}
	return tb_attrs
end

--------------------------------------------------------
-- 编辑器风格绘制
--------------------------------------------------------
local function new()
	---@class ly.game_editor.style.draw  --- 使用
	local api = {}
	api.styles = {}

	local function init_callbacks(type, tb_data, tb_attrs)
		local c_color = 0
		local c_var = 0
		api.styles[type] = {
			on_push = function()
				c_var, c_color = 0, 0
				for k, attr in ipairs(tb_attrs) do 
					local type, name, tip, enum, default = table.unpack(attr)
					local value = tb_data[name]
					if type == "col" then 
						c_color = c_color + 1
						ImGui.PushStyleColorImVec4(enum, table.unpack(value or default))
					elseif type == "style_var" then  
						c_var = c_var + 1
						ImGui.PushStyleVarImVec2(enum, table.unpack(value or default))
					end
				end
			end,

			on_push = function()
				if c_color > 0 then
					ImGui.PopStyleColorEx(c_color)
				end 
				if c_var > 0 then
					ImGui.PopStyleVarEx(c_var)
				end
			end
		}
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
		local attrs = get_attrs()
		local tb_data = {}
		for i, v in pairs(tb_data) do 
			local tb_attrs = attrs[v.type]
			if tb_attrs then 
				init_callbacks(v.type, v, tb_attrs)
			else 
				log.warn("invalid style type: " .. (v.type or ""))
			end
		end
	end

	function api.draw_btn_with_style(style_name)

	end

	function api.draw_text_with_style(style_name)
	end

	api.set_theme()
	return api
end

return {
	new = new, 
	get_styles = get_styles, 
	get_attrs = get_attrs,
}