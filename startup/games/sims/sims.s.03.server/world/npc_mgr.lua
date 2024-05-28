local npc_alloc = require 'world.npc'.new

---@param server sims.s.server
---@param world sims.s.server.world
local function new(world, server)
	---@class sims.s.server.npc_mgr
	---@field npcs map<number, sims.s.server.npc>
	---@field player_npcs map<number, sims.s.server.npc>
	local api = {npcs = {}, player_npcs = {}}

	function api.get_npc(id)
		local npc = api.npcs[id]
		assert(npc)
		return npc
	end

	---@return sims.s.server.npc
	function api.get_player_npc(player_id)
		return api.player_npcs[player_id]
	end

	--- center通知创建npc
	---@param tbParam sims.s.server.npc
	function api.create_npc(tbParam)
		local npc = npc_alloc(api, world, server)
		npc.id = tbParam.id
		npc.player_id = tbParam.player_id
		npc.pos_x = tbParam.pos_x;
		npc.pos_y = tbParam.pos_y
		npc.pos_z = tbParam.pos_z
		npc.tplId = tbParam.tplId
		npc.dir_x = tbParam.dir_x
		npc.dir_z = tbParam.dir_z
		api.npcs[npc.id] = npc
		if tbParam.player_id and tbParam.player_id > 0 then 
			api.player_npcs[tbParam.player_id] = npc
		end
		return npc
	end

	function api.tick(totalTime, deltaSecond)
		for id, npc in pairs(api.npcs) do 
			npc.tick(deltaSecond)
		end
	end

	return api
end

return {new = new}