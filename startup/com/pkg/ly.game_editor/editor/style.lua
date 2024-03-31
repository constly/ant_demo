local dep = require 'dep' ---@type ly.game_editor.dep
local ImGui = dep.ImGui

--------------------------------------------------------
-- 编辑器风格样式定义
--------------------------------------------------------
---@class ly.game_editor.style 风格定义
GStyle = {}

--------------------------------------------------------
--- 通用
--------------------------------------------------------
GStyle.btn_normal = "gen.btn_normal"
GStyle.btn_normal_selected = "gen.btn_normal_selected"
GStyle.tab_active = "gen.tab_active"

--------------------------------------------------------
--- 文件
--------------------------------------------------------
GStyle.btn_transp_center = "gen.btn_transp_center"
GStyle.btn_transp_center_sel = "gen.btn_transp_center_sel"
GStyle.btn_transp_center_active = "gen.btn_transp_center_active"

--------------------------------------------------------
--- 表格
--------------------------------------------------------
GStyle.cell_header = "cell.cell_header"
GStyle.cell_body = "cell.cell_body"
GStyle.cell_selected = "cell.cell_selected"
GStyle.cell_input = "cell.cell_input"


GStyle.popup = "popup"






GStyle.btn_drop_hint = 1000


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
types.input = "input"
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

	reg("通 用", 	GStyle.btn_normal, 					types.button, 	"按钮普通状态")
	reg("通 用", 	GStyle.btn_normal_selected, 		types.button, 	"按钮选中状态")
	reg("通 用", 	GStyle.tab_active, 					types.button, 	"tab页激活状态")

	reg("文件栏", 	GStyle.btn_transp_center, 			types.button, 	"透明-中心对齐")
	reg("文件栏", 	GStyle.btn_transp_center_sel, 		types.button, 	"文件选中非激活")
	reg("文件栏", 	GStyle.btn_transp_center_active, 	types.button, 	"文件选中激活")
	
	
	reg("表 格", 	GStyle.cell_header, 				types.cell, 	"表格头部")
	reg("表 格", 	GStyle.cell_body, 					types.cell, 	"表格内容")
	reg("表 格", 	GStyle.cell_selected, 				types.cell, 	"表格选中")
	reg("表 格", 	GStyle.cell_input, 					types.input, 	"表格输入框")

	return all
end


local function get_attrs()
	local tb_attrs = {}
	tb_attrs[types.button] = {
		-- 类型	变量名	变量说明	imgui枚举	默认值
		{"col", 		"normal", 		"正常显示", 		ImGui.Col.Button, 				{0.2, 0.2, 0.2, 1}},
		{"col", 		"hovered", 		"鼠标悬停", 		ImGui.Col.ButtonHovered,		{0.35, 0.35, 0.3, 1}},
		{"col", 		"active", 		"激活", 			ImGui.Col.ButtonActive, 		{0.3, 0.3, 0.3, 1}},
		{"col", 		"text", 		"文本颜色", 		ImGui.Col.Text,					{0.8, 0.8, 0.8, 1}},
		{"style_var", 	"text_align", 	"文本对齐", 		ImGui.StyleVar.ButtonTextAlign, {0.5, 0.5}},
	}

	tb_attrs[types.text]	= {
		{"col", 		"text", 		"文本颜色", 		ImGui.Col.Text,					{0.9, 0.9, 0.9, 1}},
	}

	tb_attrs[types.popup]	= {
		{"col", 		"dimbg", 		"弹框背景", 		ImGui.Col.ModalWindowDimBg,		{0.1, 0.1, 0.1, 1}},
		{"col", 		"bg", 			"窗口背景", 		ImGui.Col.WindowBg,				{0.5, 0.5, 0.5, 0.5}},
	}

	tb_attrs[types.cell]	= {
		{"cell_bg", 	"bg", 			"背景颜色", 		ImGui.TableBgTarget.CellBg,		{0.9, 0.9, 0.9, 1}},
		{"col", 		"text", 		"文本颜色", 		ImGui.Col.Text,					{0, 0, 0, 1}},
		{"col", 		"normal", 		"正常显示", 		ImGui.Col.Button, 				{0, 0, 0, 0}, {hide = true}},
		{"col", 		"hovered", 		"鼠标悬停", 		ImGui.Col.ButtonHovered,		{0, 0, 0, 0}, {hide = true}},
		{"col", 		"active", 		"激活", 			ImGui.Col.ButtonActive, 		{0, 0, 0, 0}, {hide = true}},
	}

	tb_attrs[types.input]	= {
		{"col", 		"bg", 			"文本背景", 		ImGui.Col.FrameBg,				{0.2, 0.2, 0.2, 1}},
		{"col", 		"text", 		"文本颜色", 		ImGui.Col.Text,					{0.9, 0.9, 0.9, 1}},
	}
	return tb_attrs
end

--------------------------------------------------------
-- 编辑器风格绘制
--------------------------------------------------------
---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.style.draw  --- 使用
	local api = {}
	api.styles = {}

	local function init_callbacks(type, tb_data, tb_attrs)
		local c_color = 0
		local c_var = 0
		local values = tb_data.values
		api.styles[type] = {
			on_push = function()
				c_var, c_color = 0, 0
				for k, attr in ipairs(tb_attrs) do 
					local type, name, tip, enum, default = table.unpack(attr)
					local value = values[name]
					if type == "col" then 
						c_color = c_color + 1
						ImGui.PushStyleColorImVec4(enum, table.unpack(value or default))
					elseif type == "style_var" then  
						c_var = c_var + 1
						ImGui.PushStyleVarImVec2(enum, table.unpack(value or default))
					elseif type == "cell_bg" then 
						local color = ImGui.GetColorU32ImVec4(table.unpack(value or default))
						ImGui.TableSetBgColor(enum, color)
					end
				end
			end,

			on_pop = function()
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
	---@param data string|ly.game_editor.style.data 主题路径或者数据
	function api.set_theme(data)
		assert(data, "请输入主题文件路径或者数据")
		if type(data) == "string" then 
			local real_path = editor.files.vfs_path_to_full_path(data)
			data = require 'windows.utils' .load_datalist(real_path)
		end
		if type(data) ~= "table" or not data.styles then 
			log.warn("主题文件格式异常")
			return;
		end

		api.styles = {}
		local attrs = get_attrs()
		local all_styles = get_styles()
		for _, category in ipairs(all_styles) do 
			for _, item in ipairs(category.list) do 
				local tb_attrs = attrs[item.type]
				local style = data.styles[item.name]
				if tb_attrs and style then 
					init_callbacks(item.name, style, tb_attrs)
				end
			end
		end
	end

	--- 绘制按钮
	---@param label string 
	---@param selected boolean 是否选中
	---@param tbParams table 扩展参数{size_x = 100, size_y = 100}
	function api.draw_btn(label, selected, tbParams)
		local use<close> = api.use(selected and GStyle.btn_normal_selected or GStyle.btn_normal)
		tbParams = tbParams or {}
		return ImGui.ButtonEx(label, tbParams.size_x, tbParams.size_y)
	end

	--- 绘制按钮
	---@param label string 
	---@param style_type ly.game_editor.style
	---@param tbParams table 扩展参数{size_x = 100, size_y = 100}
	function api.draw_style_btn(label, style_type, tbParams)
		local use<close> = api.use(style_type)
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

	---@return number,number 得到显示窗口大小
	function api.get_display_size()
		local viewport = ImGui.GetMainViewport();
		return viewport.WorkSize.x, viewport.WorkSize.y
	end

	---@return number 
	function api.get_dpi_scale()
		return ImGui.GetMainViewport().DpiScale
	end

	--- 中间居中绘制文本
	function api.draw_text_center(text)
		local size_x, _ = ImGui.GetContentRegionAvail()
		local len = ImGui.CalcTextSize(text)
		ImGui.Dummy((size_x - len) * 0.5 - 15, 20)
		ImGui.SameLine()
		ImGui.Text(text)
	end
		
	api.set_theme(editor.tbParams.theme_path)
	return api
end

return {
	new = new, 
	get_styles = get_styles, 
	get_attrs = get_attrs,
}