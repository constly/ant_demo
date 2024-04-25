
---@param server sims.server
local function new(server)
	---@class sims.server.map_mgr
	---@field maps sims.server.map<int, sims.server.map> 地图列表
	---@field next_id number
	local api = {maps = {}}

	--------------------------------------------------
	-- 存档 和 读档
	--------------------------------------------------
	function api.to_save_data()
		---@type sims.save.map_data
		local data = {}
		data.next_id = api.next_id
		data.maps = {}
		for i, map in pairs(api.maps) do 
			---@type sims.save.map
			local tb = {}
			tb.id = map.id
			tb.tpl_id = map.tpl_id
			tb.grid_deleted = {}
			tb.grids = {}
			table.insert(data.maps, tb)
		end
		return data
	end

	---@param data sims.save.map_data
	---@param npc_data sims.save.npc_data
	function api.load_from_save(data, npc_data)
		api.next_id = data.next_id or 0
		api.maps = {}
		for i, map in ipairs(data.maps or {}) do 
			local data = require 'map.server_map'.new(api, server)
			data.init(map.id, map.tpl_id, map, npc_data)
			api.maps[map.id] = data
		end

		if api.next_id == 0 then
			api.create_map("1", false)
		end
	end

	--------------------------------------------------
	-- 创建 和 销毁地图
	--------------------------------------------------
	---@param tpl_id string 地图模板id
	---@param is_dynamic boolean 是不是动态地图
	function api.create_map(tpl_id, is_dynamic)
		local map = require 'map.server_map'.new(api, server)
		api.next_id = api.next_id + 1
		local id = api.next_id
		map.init(id, tpl_id, nil)
		api.maps[id] = map
	end

	---@param player sims.server_player 玩家对象
	function api.on_login(player)
		local map = api.find_map_by_tpl_id("1")
		player.map_id = map.id
		map.on_login(player)
	end

	---@param player sims.server_player 玩家对象
	function api.on_logout(player)
		local map = api.find_map_by_id(player.map_id)
		map.on_logout(player.npc)
	end

	function api.find_map_by_id(id)
		return api.maps[id]
	end

	function api.find_map_by_tpl_id(tpl_id)
		for i, v in pairs(api.maps) do 
			if v.tpl_id == tpl_id then 
				return v
			end
		end
	end

	--------------------------------------------------
	-- 每帧更新
	--------------------------------------------------
	function api.tick(delta_time)
		for map_id, map in pairs(api.maps) do 
			map.tick(delta_time)
		end
	end

	return api
end

return {new = new}