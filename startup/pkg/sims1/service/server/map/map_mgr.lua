
---@param server sims1.server
local function new(server)
	---@class sims1.server.map_mgr
	---@field next_dynamic_map_id number 下个动态地图id
	---@field maps sims1.server.map<int, sims1.server.map> 地图列表
	local api = {}
	api.maps = {}
	api.next_dynamic_map_id = 10000;
	
	local function init()
		api.create_map("1", false)
	end

	---@param tpl_id string 地图模板id
	---@param is_dynamic boolean 是不是动态地图
	function api.create_map(tpl_id, is_dynamic)
		local map = require 'service.server.map.server_map'.new(api, server)
		api.next_dynamic_map_id = api.next_dynamic_map_id + 1
		local id = api.next_dynamic_map_id
		map.init(id, tpl_id)
		api.maps[id] = map
	end

	---@param player sims1.server_player 玩家对象
	function api.on_login(player)
		local map = api.find_map_by_tpl_id("1")
		map.on_login(player.npc)
	end

	---@param player sims1.server_player 玩家对象
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

	init();
	return api
end

return {new = new}