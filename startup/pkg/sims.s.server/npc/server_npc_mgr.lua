---@param server sims.server
local function new(server)
	---@class sims.server.npc_mgr
	---@field npcs sims.server.npc[] npc列表
	local api = {}
	local next_id = 0

	function api.restart()
		api.npcs = {}
		next_id = 0;
	end

	--- 创建npc
	---@return sims.server.npc
	function api.create_npc()
		next_id = next_id + 1
		local npc = require 'npc.server_npc'.new(server)
		npc.id = next_id
		api.npcs[npc.id] = npc
		return npc
	end

	--- 销毁npc
	---@param npc sims.server.npc
	function api.destroy_npc(npc)
		api.npcs[npc.id] = nil
	end

	return api
end	

return {new = new}