
---@param server sims.server
local function new(server)
	---@class sims.server.map_mgr
	---@field maps sims.server.map<int, sims.server.map> 地图列表
	local api = {}
	local next_id = 0

	function api.restart()
		next_id = 0
		api.maps = {}
		api.create_map("1", false)
	end

	---@param tpl_id string 地图模板id
	---@param is_dynamic boolean 是不是动态地图
	function api.create_map(tpl_id, is_dynamic)
		local map = require 'map.server_map'.new(api, server)
		next_id = next_id + 1
		local id = next_id
		map.init(id, tpl_id)
		api.maps[id] = map
	end

	---@param player sims.server_player 玩家对象
	function api.on_login(player)
		local map = api.find_map_by_tpl_id("1")
		map.on_login(player.npc)
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

	return api
end

return {new = new}