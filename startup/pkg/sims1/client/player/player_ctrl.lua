--------------------------------------------------------------
--- 客户端玩家控制器
--------------------------------------------------------------

---@param client sims1.client
local function new(client)
	---@class sims1.client.player_ctrl
	local api = {}

	function api.restart()

	end

	--- 设置操控的npc
	---@param npc sims1.client.npc
	function api.set_npc(npc)

	end

	return api
end

return {new = new}