---@param api ly.game_editor.data_def
local function reg(api)
	local dep = require 'dep'
	local ImGui = dep.ImGui
	local input_content = ImGui.StringBuf()

	-- data_type
	api.reg_type({}, "data_type", nil, {name = "数据类型", hint = nil, range = {min = nil, max = nil}})
	api.reg_type_inspector("data_type", function(type_data, draw_data)
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)

		ImGui.SetNextItemWidth(draw_data.content_len)
		local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
		if ImGui.BeginCombo(label, draw_data.value) then
			for i, name in ipairs(api.tb_type_list) do
				if ImGui.Selectable(name, name == draw_data.value) then
					if draw_data.value ~= name then 
						draw_data.new_value = name
					end
				end
				if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
					local type = api.get_type(name)
					if type and type.params then
						ImGui.Text(type.params.name or name)
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
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)

		input_content:Assgin(tostring(draw_data.value))
		ImGui.SetNextItemWidth(draw_data.content_len)
		local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
		if ImGui.InputText(label, input_content, ImGui.InputTextFlags {'AutoSelectAll', "CharsHexadecimal"}) then 
			local n = tonumber(tostring(input_content))
			draw_data.new_value = n and math.floor(n) or nil
			return draw_data.new_value ~= draw_data.value
		end
	end)

	-- number
	api.reg_type({}, "number", nil, {name = "整数和小数", hint = nil, range = {min = nil, max = nil}})
	api.reg_type_inspector("number", function(type_data, draw_data)
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)

		input_content:Assgin(tostring(draw_data.value or 0))
		ImGui.SetNextItemWidth(draw_data.content_len)
		local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
		if ImGui.InputText(label, input_content, ImGui.InputTextFlags {'AutoSelectAll', "CharsDecimal"}) then 
			draw_data.new_value = tonumber(tostring(input_content))
			return draw_data.new_value ~= draw_data.value
		end
	end)

	-- string
	api.reg_type({}, "string", nil, {name = "字符串", hint = nil})
	api.reg_type_inspector("string", function(type_data, draw_data)
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)

		input_content:Assgin(tostring(draw_data.value or ""))
		ImGui.SetNextItemWidth(draw_data.content_len)
		local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
		if ImGui.InputText(label, input_content, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue"}) then 
			draw_data.new_value = tostring(input_content)
			return draw_data.new_value ~= draw_data.value
		end
	end)

	-- data_opt
	api.reg_type({}, "data_opt", nil, {name = "数据操作", hint = nil, range = {min = nil, max = nil}})
	api.reg_type_inspector("data_opt", function(type_data, draw_data)
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)

		ImGui.SetNextItemWidth(draw_data.content_len)
		local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
		if ImGui.BeginCombo(label, draw_data.value or "") then
			for i, name in ipairs({"+=", "-=", "=", "*=", "/="}) do
				if ImGui.Selectable(name, name == draw_data.value) then
					if draw_data.value ~= name then 
						draw_data.new_value = name
					end
				end
			end
			ImGui.EndCombo()
		end
		return draw_data.new_value ~= nil
	end)

	-- data_compare
	api.reg_type({}, "data_compare", nil, {name = "数据比较", hint = nil, range = {min = nil, max = nil}})
	api.reg_type_inspector("data_compare", function(type_data, draw_data)
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)

		ImGui.SetNextItemWidth(draw_data.content_len)
		local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
		if ImGui.BeginCombo(label, tostring(draw_data.value) or "") then
			for i, name in ipairs({">", ">=", "<", "<=", "==", "!="}) do
				if ImGui.Selectable(name, name == draw_data.value) then
					if draw_data.value ~= name then 
						draw_data.new_value = name
					end
				end
			end
			ImGui.EndCombo()
		end
		return draw_data.new_value ~= nil
	end)
end

return {reg = reg}