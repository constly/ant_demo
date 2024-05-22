local npc_alloc = require 'npc.npc'.new

---@param server sims.s.server
local function new(server)
	---@class sims.s.server.npc_mgr
	---@field npcs map<number, sims.s.server.npc>
	local api = {npcs = {}}

	function api.get_npc(id)
		local npc = api.npcs[id]
		assert(npc)
		return npc
	end

	--- center通知创建npc
	---@param tbParam sims.s.server.npc
	function api.create_npc(tbParam)
		local npc = npc_alloc(api, server)
		npc.id = tbParam.id
		npc.player_id = tbParam.player_id
		npc.pos_x = tbParam.pos_x;
		npc.pos_y = tbParam.pos_y
		npc.pos_z = tbParam.pos_z
		api.npcs[npc.id] = npc
	end

	function api.tick(totalTime, deltaSecond)
		for id, npc in pairs(api.npcs) do 
			npc.tick(deltaSecond)
		end
	end

	return api
end

return {new = new}