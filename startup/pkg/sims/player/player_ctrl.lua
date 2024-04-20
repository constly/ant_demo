--------------------------------------------------------------
--- 客户端玩家控制器
--------------------------------------------------------------

---@param client sims.client
local function new(client)
	---@class sims.client.player_ctrl
	local api = {}
	local entity

	function api.restart()
		-- if entity then 
		-- 	client.world:remove_entity(entity)
		-- 	entity = nil
		-- end

		-- -- 创建玩家控制器
		-- entity = client.world:create_entity {
		-- 	policy = { "sims|player" },
		-- 	data = {
		-- 		comp_input_process = {},
		-- 	}
		-- }

	end

	--- 设置操控的npc
	---@param npc sims.client.npc
	function api.set_npc(npc)

	end

	return api
end

return {new = new}