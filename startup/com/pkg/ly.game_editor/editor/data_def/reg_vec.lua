---@param api ly.game_editor.data_def
local function reg(api)
	local dep = require 'dep'
	local ImGui = dep.ImGui
	local lib = dep.common.lib
	local input_content = ImGui.StringBuf()

	-- vec2
	api.reg_type({}, "vec2", nil, {name = "二维向量-浮点数", hint = nil})
	api.reg_type_inspector("vec2", function(type_data, draw_data)
		api.draw_header(draw_data)
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
		api.draw_header(draw_data)
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

end 

return {reg = reg}