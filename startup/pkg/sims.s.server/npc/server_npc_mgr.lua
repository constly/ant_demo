---@class sims.server.npc.create_param
---@field tplId number npc模板id
---@field mapId number 所在地图id 
---@field pos_x number 坐标x
---@field pos_y number 坐标y
---@field pos_z number 坐标z


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

	--- 创建玩家npc
	---@param player sims.server_player
	function api.create_player_npc(player)
		---@class sims.server.npc.create_param
		local params = {}
		params.mapId = 1
		params.tplId = 1
		return api.create_npc(params)
	end

	--- 创建npc
	---@return sims.server.npc
	---@param params sims.server.npc.create_param
	function api.create_npc(params)
		next_id = next_id + 1
		local npc = require 'npc.server_npc'.new(server)
		npc.init(next_id, params)
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