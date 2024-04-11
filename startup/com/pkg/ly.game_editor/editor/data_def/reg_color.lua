---@param api ly.game_editor.data_def
local function reg(api)
	local dep = require 'dep'
	local ImGui = dep.ImGui
	local lib = dep.common.lib
	local input_content = ImGui.StringBuf()

	-- color
	api.reg_type({}, "color", nil, {name = "颜色", hint = nil})
	api.reg_type_inspector("color", function(type_data, draw_data)
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)
		ImGui.SetNextItemWidth(draw_data.content_len)

		local precision = draw_data.precision or 3
		local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
		local flag = ImGui.ColorEditFlags { "None", "Float" } 
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
					return lib.float_format(tb[idx], precision)
				end
				draw_data.new_value = string.format("{%s,%s,%s,%s}", get(1), get(2), get(3), get(4))
				return true
			end
		end
	end)

end 

return {reg = reg}