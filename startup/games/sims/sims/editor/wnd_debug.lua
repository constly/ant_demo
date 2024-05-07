-----------------------------------------------------------------------
--- 开发计划界面
-----------------------------------------------------------------------

---@param client sims.client
local function new(client)
	local api = {}
	local ImGui  = require "imgui"

	function api.update(is_active, delta_time)
		local pos = client.player_ctrl.position
		if not pos or not pos.x then return end 

		local grid_x, grid_y, grid_z = client.define.world_pos_to_grid_pos(pos.x, pos.y, pos.z)
		local height = client.client_world.c_world:GetGroundHeight(grid_x, grid_y + 5, grid_z)

		ImGui.BeginGroup()
		ImGui.Text("调试面板:")

		ImGui.Text("玩家位置: %.2f, %.2f, %.2f", pos.x, pos.y, pos.z)
		ImGui.Text("玩家格子: %d, %d, %d", grid_x, grid_y, grid_z)
		ImGui.Text("格子高度: %.2f", height)
		ImGui.EndGroup()
	end

	return api
end

return {new = new}