--------------------------------------------------------
--代码分析 界面渲染
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.code.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.code.renderer
	local api = {}

	function api.reload()
		data_hander.reload()
		stack.set_data_handler(data_hander)
	end

	local function draw_body()
		local n = 2
		if ImGui.BeginTable("table1", n, ImGui.TableFlags {'BordersInnerH', 'Borders', }) then
			ImGui.TableSetupColumnEx("pkg", ImGui.TableColumnFlags {'WidthStretch'}, 220);
			ImGui.TableSetupColumnEx("lua", ImGui.TableColumnFlags {'WidthStretch'}, 80);
			ImGui.TableHeadersRow();

			for i, v in ipairs(data_hander.data) do 
				ImGui.TableNextRow();
				ImGui.TableNextColumn()
				ImGui.Text(v.name)
				ImGui.TableNextColumn()
				ImGui.Text(v.lua)
			end
			ImGui.EndTable()
		end
	end

	function api.update(delta_time)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(10, 10)
		ImGui.BeginChild("detail", 300, size_y - 30, ImGui.ChildFlags({"Border"}))
		draw_body()
		ImGui.EndChild()
	end

	return api
end 

return {new = new}