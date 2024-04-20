---@param server sims1.server
local function new(server)
	---@class sims1.server.npc_mgr
	---@field npcs sims1.server.npc[] npc列表
	local api = {}
	local next_id = 0

	function api.restart()
		api.npcs = {}
		next_id = 0;
	end

	--- 创建npc
	---@return sims1.server.npc
	function api.create_npc()
		next_id = next_id + 1
		local npc = require 'service.server.npc.npc'.new(server)
		npc.id = next_id
		api.npcs[npc.id] = npc
		return npc
	end

	--- 销毁npc
	---@param npc sims1.server.npc
	function api.destroy_npc(npc)
		api.npcs[npc.id] = nil
	end

	return api
end	

return {new = new}