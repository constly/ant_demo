local dep = require 'dep'
local ImGui = dep.ImGui
local lib = dep.common.lib

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.data_def
	local api = {}
	api.types = {}

	---@type string[]
	api.tb_type_list = {}

	function api.get_type(type, auto_create)
		local tb_data = api.types[type]
		if not tb_data and auto_create then 
			tb_data = {}
			api.types[type] = tb_data
			table.insert(api.tb_type_list, type)
		end
		return tb_data
	end

	-- 得到类型列表
	function api.get_type_list()
		return api.tb_type_list
	end

	function api.remove_type(type)
		api.types[type] = nil
	end 

	--- 注册数据类型
	function api.reg_type(tags, type, base_type, params)
		local tb_data = api.get_type(type, true)
		tb_data.params = params
		tb_data.tags = tags
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
			return ImGui.Text("unknown type: " .. type)
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
		return ImGui.Text("unknown type: " .. type)
	end 

	function api.draw_header(draw_data)
		if draw_data.active then 
			ImGui.TextColored(0, 0.9, 0, 1, draw_data.header)
		else 
			ImGui.Text(draw_data.header)
		end

		if draw_data.header_tip then 
			if ImGui.BeginItemTooltip() then 
				ImGui.Text(draw_data.header_tip)
				ImGui.EndTooltip()
			end
		end
	end

	local function init()
		api.types = {}
		api.tb_type_list = {}

		require 'editor.data_def.reg_common'.reg(api)
		require 'editor.data_def.reg_color'.reg(api)
		require 'editor.data_def.reg_vec'.reg(api)
		require 'editor.data_def.reg_attr'.reg(api)

		-- test
		-- api.reg_type({}, "test_int", "int", {name = "整数", hint = "", range = {min = 1, max = 2}})
	end


	init()
	return api
end 

return {new = new}