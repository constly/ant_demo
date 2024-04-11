---@param api ly.game_editor.data_def
local function reg(api)
	local dep = require 'dep'
	local ImGui = dep.ImGui
	local lib = dep.common.lib
	local input_content = ImGui.StringBuf()

	-- attr_type
	api.reg_type({"attr"}, "attr_type", nil, {name = "属性类型"})
	api.reg_type_inspector("attr_type", function(type_data, draw_data)
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)

		---@type ly.game_editor.attr.handler
		local attr_handler = draw_data.attr_handler
		if not attr_handler then ImGui.Text("未设置attr_handler") end

		ImGui.SetNextItemWidth(draw_data.content_len)
		local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
		if attr_handler and ImGui.BeginCombo(label, tostring(draw_data.value) or "") then
			for i, region in ipairs(attr_handler.data.regions) do
				if ImGui.Selectable(region.id, region.id == draw_data.value) then
					if draw_data.value ~= region.id then 
						draw_data.new_value = region.id
					end
				end
				if ImGui.IsItemHovered() and region.desc and ImGui.BeginTooltip() then
					ImGui.Text(region.desc)
					ImGui.EndTooltip()
				end
			end
			ImGui.EndCombo()
		end
		return draw_data.new_value ~= nil
	end)

	-- attr_key
	api.reg_type({"attr"}, "attr_key", nil, {name = "属性类型"})
	api.reg_type_inspector("attr_key", function(type_data, draw_data)
		api.draw_header(draw_data)
		ImGui.SameLineEx(draw_data.header_len)

		---@type ly.game_editor.attr.handler
		local attr_handler = draw_data.attr_handler
		if not attr_handler then ImGui.Text("未设置attr_handler") end

		ImGui.SetNextItemWidth(draw_data.content_len)
		local label = string.format("##detail_%s_%s", draw_data.header, draw_data.id or 0)
		if attr_handler and ImGui.BeginCombo(label, tostring(draw_data.value) or "") then
			local tb = attr_handler.get_region(draw_data.attr_type)
			if tb then
				for i, attr in ipairs(tb.attrs) do
					if ImGui.Selectable(attr.id, attr.id == draw_data.value) then
						if draw_data.value ~= attr.id then 
							draw_data.new_value = attr.id
						end
					end
					if ImGui.IsItemHovered() and attr.desc and ImGui.BeginTooltip() then
						ImGui.Text(attr.desc)
						ImGui.EndTooltip()
					end
				end
			end
			ImGui.EndCombo()
		end
		return draw_data.new_value ~= nil
	end)
end 

return {reg = reg}