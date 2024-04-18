---@param server sims1.server
local function new(server)
	---@class sims1.server.npc_mgr
	---@field npcs sims1.server.npc[] npc列表
	local api = {}
	api.npcs = {}
	api.next_id = 0

	--- 创建npc
	---@return sims1.server.npc
	function api.create_npc()
		api.next_id = api.next_id + 1
		local npc = require 'service.server.npc.npc'.new(server)
		npc.id = api.next_id
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