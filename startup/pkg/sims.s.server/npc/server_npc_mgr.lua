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
	---@field next_id number 
	local api = {}

	--------------------------------------------------
	-- 存档 和 读档
	--------------------------------------------------
	function api.to_save_data()
		---@type sims.save.npc_data
		local tb = {}
		tb.next_id = api.next_id
		tb.npcs = {}
		for i, npc in pairs(api.npcs) do 
			---@type sims.save.npc
			local tb = {}
			tb.id = npc.id
			tb.tpl_id = npc.tplId
			tb.map_id = npc.map_id
			tb.pos_x = npc.pos_x
			tb.pos_y = npc.pos_y
			tb.pos_z = npc.pos_z
			table.insert(tb.npcs, tb)
		end
		return tb
	end

	---@param data sims.save.npc_data
	function api.load_from_save(data)
		api.next_id = data.next_id or 0
		api.npcs = {}
		for i, npc in ipairs(data.npcs or {}) do 
			-- create npc
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
	function api.create_npc(params)
		api.next_id = api.next_id + 1
		local npc = require 'npc.server_npc'.new(server)
		npc.init(api.next_id, params)
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