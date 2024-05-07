---@param api ly.game_editor.data_def
local function reg(api)
	local dep = require 'dep'
	local ImGui = dep.ImGui
	local lib = dep.common.lib

	local tb_grid_type = {
		{key = "ground", hint = "地形"},
		{key = "object", hint = "物件"},
		{key = "art", 	hint = "装饰"},
		{key = "logic", hint = "逻辑"},
	}

	local function reg_enum(type, name, list)
		api.reg_type({}, type, nil, {name = name, type = "enum"})
		api.reg_type_inspector(type, function(type_data, draw_data)
			api.draw_header(draw_data)
			ImGui.SameLineEx(draw_data.header_len)

			ImGui.SetNextItemWidth(draw_data.content_len)
			local label = string.format("##detail_%s_%d", draw_data.header, draw_data.id or 0)
			if ImGui.BeginCombo(label, tostring(draw_data.value) or "") then
				for i, one in ipairs(list) do
					local _name = one.key
					local hint = string.format("%s-%s", one.key, one.hint)
					if ImGui.Selectable(hint, _name == draw_data.value) then
						if draw_data.value ~= _name then 
							draw_data.new_value = _name
						end
					end
				end
				ImGui.EndCombo()
			end
			return draw_data.new_value ~= nil
		end)
	end

	reg_enum("grid_type", "格子类型", tb_grid_type)
end


return {reg = reg}