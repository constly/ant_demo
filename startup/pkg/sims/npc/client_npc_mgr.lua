-----------------------------------------------------------------------
--- 客户端npc管理
-----------------------------------------------------------------------
---@param client sims.client
local function new(client)
	---@class sims.client.npc_mgr
	---@field npcs map<int, sims.client.npc>
	local api = {npcs = {}}

	function api.restart()
		for i, npc in pairs(api.npcs or {}) do 
			npc.destroy()
		end
		api.npcs = {}
	end

	---@param syncNpc sims.server.npc.sync
	function api.create_npc(syncNpc)
		local npc = require 'npc.client_npc'.new(client)
		npc.init(syncNpc)
		api.npcs[npc.id] = npc
	end

	function api.get_npc_by_id(id)
		return api.npcs[id]
	end

	return api
end

return {new = new}