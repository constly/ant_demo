local dep = require 'dep'
local ImGui = dep.ImGui
local lib = dep.common.lib
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

	local function init()
		local function draw_header(draw_data)
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

		-- data_type
		api.reg_type({}, "data_type", nil, {name = "数据类型", hint = nil, range = {min = nil, max = nil}})
		api.reg_type_inspector("data_type", function(type_data, draw_data)
			draw_header(draw_data)
			ImGui.SameLineEx(draw_data.header_len)

			input_content:Assgin(tostring(draw_data.value))
			ImGui.SetNextItemWidth(draw_data.content_len)
			local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
			if ImGui.BeginCombo(label, draw_data.value) then
				for i, name in ipairs(tb_type_list) do
					if ImGui.Selectable(name, name == draw_data.value) then
						if draw_data.value ~= name then 
							draw_data.new_value = name
						end
					end
					if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
						local type = api.get_type(name)
						if type and type.data then
							ImGui.Text(type.data.name or name)
						end
						ImGui.EndTooltip()
					end
				end
				ImGui.EndCombo()
			end
			return draw_data.new_value ~= nil
		end)

		-- int
		api.reg_type({}, "int", nil, {name = "整数", hint = nil, range = {min = nil, max = nil}})
		api.reg_type_inspector("int", function(type_data, draw_data)
			draw_header(draw_data)
			ImGui.SameLineEx(draw_data.header_len)

			input_content:Assgin(tostring(draw_data.value))
			ImGui.SetNextItemWidth(draw_data.content_len)
			local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
			if ImGui.InputText(label, input_content, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue", "CharsHexadecimal"}) then 
				local n = tonumber(tostring(input_content))
				draw_data.new_value = n and math.floor(n) or nil
				return draw_data.new_value ~= draw_data.value
			end
		end)

		-- number
		api.reg_type({}, "number", nil, {name = "整数和小数", hint = nil, range = {min = nil, max = nil}})
		api.reg_type_inspector("number", function(type_data, draw_data)
			draw_header(draw_data)
			ImGui.SameLineEx(draw_data.header_len)

			input_content:Assgin(tostring(draw_data.value))
			ImGui.SetNextItemWidth(draw_data.content_len)
			local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
			if ImGui.InputText(label, input_content, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue", "CharsDecimal"}) then 
				draw_data.new_value = tonumber(tostring(input_content))
				return draw_data.new_value ~= draw_data.value
			end
		end)

		-- string
		api.reg_type({}, "string", nil, {name = "字符串", hint = nil})
		api.reg_type_inspector("string", function(type_data, draw_data)
			draw_header(draw_data)
			ImGui.SameLineEx(draw_data.header_len)

			input_content:Assgin(tostring(draw_data.value))
			ImGui.SetNextItemWidth(draw_data.content_len)
			local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
			if ImGui.InputText(label, input_content, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue"}) then 
				draw_data.new_value = tostring(input_content)
				return draw_data.new_value ~= draw_data.value
			end
		end)

		-- vec2
		api.reg_type({}, "vec2", nil, {name = "二维向量-浮点数", hint = nil})
		api.reg_type_inspector("vec2", function(type_data, draw_data)
			draw_header(draw_data)
			ImGui.SameLineEx(draw_data.header_len)
			ImGui.SetNextItemWidth(draw_data.content_len)
			local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
			local precision = draw_data.precision or 3
			local format = "%." .. precision  .. "f"
			if draw_data.is_table or type_data.params.is_table then 
				local tb = (type(draw_data.value) == "table") and draw_data.value or {} 
				if ImGui.DragFloat2Ex(label, tb, nil, nil, nil, format) then 
					draw_data.new_value = {tb[1], tb[2]}
					return true
				end
			else 
				local str = draw_data.value or ""
				if #str >= 2 then str = str.sub(str, 2, -2) end
				local arr = lib.split(str, ",")
				local x = tonumber(arr[1]) or 0
				local y = tonumber(arr[2]) or 0
				local new_x, new_y = x, y
				local tb = {x, y}
				if ImGui.DragFloat2Ex(label, tb, nil, nil, nil, format) then
					new_x, new_y = tb[1], tb[2]
				end
				if new_x ~= x or new_y ~= y then 
					if new_x == 0 and new_y == 0 then 
						draw_data.new_value = ""
					else 
						draw_data.new_value = string.format("{%s, %s}", lib.float_format(new_x, precision), lib.float_format(new_y, precision))
					end
					return true
				end
			end
		end)

		-- vec2_int
		api.reg_type({}, "vec2_int", nil, {name = "二维向量-整数", hint = nil})
		api.reg_type_inspector("vec2_int", function(type_data, draw_data)
			draw_header(draw_data)
			ImGui.SameLineEx(draw_data.header_len)
			ImGui.SetNextItemWidth(draw_data.content_len)
			local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)

			if draw_data.is_table or type_data.params.is_table then 
				local tb = (type(draw_data.value) == "table") and draw_data.value or {} 
				if ImGui.DragInt2(label, tb) then 
					draw_data.new_value = {tb[1], tb[2]}
					return true
				end
			else
				local str = draw_data.value or ""
				str = str.sub(str, 2, -2)
				local arr = lib.split(str, ",")
				local x = math.floor(tonumber(arr[1]) or 0)
				local y = math.floor(tonumber(arr[2]) or 0)
				local new_x, new_y = x, y
				local tb = {x, y}
				if ImGui.DragInt2(label, tb) then
					new_x, new_y = tb[1], tb[2]
				end
				if new_x ~= x or new_y ~= y then 
					if new_x == 0 and new_y == 0 then 
						draw_data.new_value = ""
					else 
						draw_data.new_value = string.format("{%s, %s}", new_x, new_y)
					end
					return true
				end
			end
		end)

		-- color
		api.reg_type({}, "color", nil, {name = "颜色", hint = nil})
		api.reg_type_inspector("color", function(type_data, draw_data)
			draw_header(draw_data)
			ImGui.SameLineEx(draw_data.header_len)
			ImGui.SetNextItemWidth(draw_data.content_len)

			local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
			local flag = draw_data.is_float and ImGui.ColorEditFlags { "None", "Float" } or ImGui.ColorEditFlags { "None" }
			if draw_data.is_table or type_data.params.is_table then 
				local tb = (type(draw_data.value) == "table") and draw_data.value or {} 
				if ImGui.ColorEdit4(label, tb, flag) then 
					draw_data.new_value = {tb[1], tb[2], tb[3], tb[4]}
					return true
				end
			else 
				local str = draw_data.value or ""
				str = str.sub(str, 2, -2)
				local arr = lib.split(str, ",")
				local x = tonumber(arr[1]) or 0
				local y = tonumber(arr[2]) or 0
				local z = tonumber(arr[3]) or 0
				local w = tonumber(arr[4]) or 0
				local tb = {x, y, z, w}
				if ImGui.ColorEdit4(label, tb, flag) then 
					local get = function(idx)
						return lib.float_format(tb[idx])
					end
					draw_data.new_value = string.format("{%s,%s,%s,%s}", get(1), get(2), get(3), get(4))
					return true
				end
			end
		end)

		api.reg_type("test_int", "int", {name = "整数", hint = "", range = {min = 1, max = 2}})
	end
	init()
	return api
end

return {new = new}
