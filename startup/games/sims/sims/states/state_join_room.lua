-----------------------------------------------------------------------
--- 加入房间
-----------------------------------------------------------------------

---@param s sims.client.state_machine
---@param client sims.client
local function new(s, client)
	local ImGui 		= require "imgui"
	---@type ly.common
	local common 		= import_package 'ly.common' 	

	local api = {} ---@type sims.client.state_machine.state_base 
	function api.on_entry()
		
	end

	function api.on_update()
		local viewport = ImGui.GetMainViewport();
		local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
		local width, height = 400, 300
		local top_x, top_y = (size_x - width) * 0.5, (size_y - height) * 0.5 - 50
		ImGui.SetNextWindowPos(top_x, top_y)
		ImGui.SetNextWindowSize(width, height);

		local window_flag = ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse"}
		local ret, open = ImGui.Begin("##window_body", true, window_flag) 
		if ret then 
			ImGui.Dummy(20, 20)
			common.imgui_utils.draw_text_center("加入房间")
			ImGui.SetCursorPos(120, 100)
			ImGui.BeginGroup()
			
			ImGui.EndGroup()
			ImGui.End()
		end
		
		if not open then
			s.goto_state(s.state_entry)
		end
	end

	function api.on_exit()
	end

	return api
end

return {new = new}