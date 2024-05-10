-----------------------------------------------------------------------
--- 客户端npc管理
-----------------------------------------------------------------------
---@param client sims.client
local function new(client)
	---@class sims.client.npc_mgr
	---@field npcs map<int, sims.client.npc>
	local api = {npcs = {}}

	function api.reset()
		for i, npc in pairs(api.npcs or {}) do 
			npc.destroy()
		end
		api.npcs = {}
	end

	---@param syncNpc sims.server.npc.s	ync
	function api.create_npc(syncNpc)
		local npc = api.npcs[syncNpc.id]
		if not npc then
			npc = require 'npc.client_npc'.new(client)
			npc.init(syncNpc)
			api.npcs[npc.id] = npc
		end
	end

	function api.get_npc_by_id(id)
		return api.npcs[id]
	end

	return api
end

return {new = new}