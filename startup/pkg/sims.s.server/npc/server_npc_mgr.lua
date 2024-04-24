---@class sims.server.npc.create_param
---@field tplId number npc模板id
---@field mapId number 所在地图id 
---@field pos_x number 坐标x
---@field pos_y number 坐标y
---@field pos_z number 坐标z


---@param server sims.server
local function new(server)
	---@class sims.server.npc_mgr
	---@field npcs map<number, sims.server.npc> npc列表
	---@field next_id number 
	local api = {}

	--------------------------------------------------
	-- 存档 和 读档
	--------------------------------------------------
	function api.to_save_data()
		---@type sims.save.npc_data
		local data = {}
		data.next_id = api.next_id
		data.npcs = {}
		data.map_npcs = {}
		for i, npc in pairs(api.npcs) do 
			local type, m = npc.get_save_data()
			if type == "map_npc" then 
				data.map_npcs[m.grid_id] = m
			else 
				table.insert(data.npcs, m)
			end
		end
		return data
	end

	---@param data sims.save.npc_data
	function api.load_from_save(data)
		api.next_id = data.next_id or 0
		api.npcs = {}
		for _, npc in ipairs(data.npcs or {}) do 
			---@type sims.server.npc.create_param
			local param = {}
			param.mapId = npc.map_id
			param.pos_x = npc.pos_x
			param.pos_y = npc.pos_y
			param.pos_z = npc.pos_z
			param.tplId = npc.tpl_id
			api.create_npc(param, npc.id)
		end
	end

	--------------------------------------------------
	-- 创建 和 销毁npc
	--------------------------------------------------
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
	function api.create_npc(params, npc_id)
		local npc = require 'npc.server_npc'.new(server)
		local id = npc_id
		if not id then 
			api.next_id = api.next_id + 1
			id = api.next_id
		end
		npc.init(id, params)
		api.npcs[npc.id] = npc
		return npc
	end

	--- 得到npc id
	function api.get_npc_by_id(npc_id)
		return api.npcs[npc_id]
	end

	--- 销毁npc
	---@param npc sims.server.npc
	function api.destroy_npc(npc)
		api.npcs[npc.id] = nil
	end

	return api
end	

return {new = new}