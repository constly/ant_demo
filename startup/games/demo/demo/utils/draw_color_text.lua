local dep = require 'dep'
local ImGui = dep.ImGui
local ImGuiExtend = dep.ImGuiExtend
local mgr = require "data_mgr"

local textColorful = nil
local api = {}


function api.convert(content)
	content = content or ""
	local tbLines = {}
	local get_pos = function (line)
		local pos1 = string.find(line, ':') 
		local pos2 = string.find(line, ' ')
		if pos1 and pos2 then 
			return math.min(pos1, pos2)
		elseif pos1 then
			return pos1
		elseif pos2 then 
			return pos2
		end
	end

	local lines = dep.common.lib.split(content, "\n")
	for i, line in ipairs(lines) do 
		local first = string.sub(line, 1, 1)
		local dest
		if dep.common.lib.start_with(dep.common.lib.trim(line), "--") then 
			dest = string.format("<color=66,155,0,255>%s</>", line)
		elseif first == ' ' or first == '\t' then 
			local pos = get_pos(line)
			if pos then 
				local str = string.sub(line, 1, pos)
				dest = string.format("<color=0,222,222,255>%s</>%s", str, string.sub(line, pos + 1))
			else
				dest = line
			end			
		else 
			local pos = string.find(line, ':') 
			if pos then 
				local str = string.sub(line, 1, pos)
				dest = string.format("<color=222,222,0,255>%s</>%s", str, string.sub(line, pos + 1))
			else 
				dest = string.format("<color=222,222,0,255>%s</>", line)
			end
		end
		table.insert(tbLines, dest);
	end
	return tbLines
end

function api.draw(tbData)
	if not textColorful then 
		textColorful = ImGuiExtend.CreateTextColor()
	end

	local width, height = ImGui.GetContentRegionAvail()
	local x, y = ImGui.GetCursorScreenPos()
	local line_y = 23 * mgr.get_dpi_scale()
	ImGui.Dummy(width, #tbData * line_y + line_y)
	for i, line in ipairs(tbData) do 
		textColorful:Render(line, x, y)
		y = y + line_y;
	end
end


return api