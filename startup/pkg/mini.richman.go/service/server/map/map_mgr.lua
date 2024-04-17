
---@param server server
local function new(server)
	---@class map_mgr
	---@field next_dynamic_map_id number 下个动态地图id
	---@field maps map<int, map> 地图列表
	local api = {}
	api.maps = {}
	api.next_dynamic_map_id = 10000;
	
	local function init()
		api.create_map(1, false)
	end

	---@param map_id number 地图id
	---@param is_dynamic boolean 是不是动态地图
	function api.create_map(map_id, is_dynamic)
		local map = require 'service.server.map.map'.new(api)
		local id = map_id
		if is_dynamic then 
			api.next_dynamic_map_id = api.next_dynamic_map_id + 1
			id = api.next_dynamic_map_id
		end
		map.init(id, map_id)
		api.maps[id] = map
	end

	init();
	return api
end

return {new = new}