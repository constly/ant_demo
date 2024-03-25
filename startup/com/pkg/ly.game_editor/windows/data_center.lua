local dep = require 'dep'
local ImGui = dep.ImGui
local input_content = ImGui.StringBuf()

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.data_center
	local api = {}
	api.types = {}

	---@type string[]
	local tb_type_list = {}

	function api.get_type(type, auto_create)
		local tb_data = api.types[type]
		if not tb_data and auto_create then 
			tb_data = {}
			api.types[type] = tb_data
			table.insert(tb_type_list, type)
		end
		return tb_data
	end

	-- 得到类型列表
	function api.get_type_list()
		return tb_type_list
	end

	function api.remove_type(type)
		api.types[type] = nil
	end 

	--- 注册数据类型
	function api.reg_type(type, base_type, data)
		local tb_data = api.get_type(type, true)
		tb_data.data = data
		tb_data.base_type = base_type
	end

	--- 注册数据类型对应的inspector面板绘制回调
	function api.reg_type_inspector(type, callback)
		local tb_data = api.get_type(type, true)
		tb_data.inspector = callback
	end 

	---@param type string 数据类型
	---@param draw_data any 绘制需要的数据
	---@return boolean isChanged
	function api.show_inspector(type, draw_data)
		local tb_data = api.get_type(type)
		if not tb_data then 
			return ImGui.Text("InValid Type: " .. type)
		end 
		local type_data = tb_data
		if tb_data.inspector then 
			return tb_data.inspector(type_data, draw_data)
		end

		while true do 
			tb_data = api.get_type(tb_data.base_type)
			if not tb_data then 
				break 
			end
			if tb_data.inspector then 
				return tb_data.inspector(type_data, draw_data)
			end
		end
		return ImGui.Text("can not find base type inspector callback: " .. type)
	end 

	local function init()
		-- int
		api.reg_type("int", nil, {name = "整数", hint = nil, range = {min = nil, max = nil}})
		api.reg_type_inspector("int", function(type_data, draw_data)
			ImGui.DrawText(draw_data.header)
			ImGui.SameLine()

			input_content:Assgin(tostring(draw_data.value))
			if ImGui.InputText(draw_data.label, input_content) then 
				draw_data.new_value = math.floor(tonumber(tostring(input_content)))
				return true
			end
		end)

		-- number
		api.reg_type("number", nil, {name = "整数和小数", hint = nil, range = {min = nil, max = nil}})
		api.reg_type_inspector("number", function(type_data, draw_data)
			ImGui.DrawText(draw_data.header)
			ImGui.SameLine()

			input_content:Assgin(tostring(draw_data.value))
			if ImGui.InputText(draw_data.label, input_content) then 
				draw_data.new_value = tonumber(tostring(input_content))
				return true
			end
		end)

		-- string
		api.reg_type("string", nil, {name = "字符串", hint = nil})
		api.reg_type_inspector("string", function(type_data, draw_data)
			ImGui.DrawText(draw_data.header)
			ImGui.SameLine()

			input_content:Assgin(tostring(draw_data.value))
			if ImGui.InputText(draw_data.label, input_content) then 
				draw_data.new_value = tostring(input_content)
				return true
			end
		end)

		api.reg_type("test_int", "int", {name = "整数", hint = "", range = {min = 1, max = 2}})
	end
	init()
	return api
end

return {new = new}
