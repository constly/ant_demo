-----------------------------------------------------------------------
--- 进入场景时，选创建房间/加入房间
-----------------------------------------------------------------------

---@param s sims.client.state_machine
---@param client sims.client
local function new(s, client)
	local ImGui 		= require "imgui"
	---@type ly.common
	local common 		= import_package 'ly.common' 	

	local api = {} ---@type sims.client.state_machine.state_base 

	function api.on_entry()
		client.destroy_room()
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
			ImGui.Dummy(20, 10)
			common.imgui_utils.draw_text_center("局域网联机")
			ImGui.SetCursorPos(120, 110)
			ImGui.BeginGroup()
			if common.imgui_utils.draw_btn("加入房间", true, {size_x = 150, size_y = 35}) then 
				s.goto_state(s.state_join_room)
			end
			ImGui.Dummy(30, 30)
			if common.imgui_utils.draw_btn("创建房间", true, {size_x = 150, size_y = 35}) then 
				s.goto_state(s.state_create_room)
			end
			ImGui.EndGroup()
			ImGui.End()
		end
		
		if not open then
			client.exitCB()
		end
	end

	function api.on_exit()

	end

	return api
end

return {new = new}