-----------------------------------------------------------------------
--- 客户端npc管理
-----------------------------------------------------------------------
---@param client sims.client
local function new(client)
	---@class sims.client.npc_mgr
	---@field npcs map<int, sims.client.npc>
	local api = {}

	function api.restart()
		for i, npc in pairs(api.npcs or {}) do 
			npc.destroy()
		end
		api.npcs = {}
		api.create_npc()
	end

	function api.create_npc()
		local npc = require 'npc.client_npc'.new(client)
		npc.init()
		api.npcs[1] = npc
	end

	return api
end

return {new = new}