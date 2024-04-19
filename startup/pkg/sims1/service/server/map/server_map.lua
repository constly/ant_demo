---@type ly.common
local common = import_package 'ly.common'
---@type ly.game_core
local game_core = import_package 'ly.game_core'

---@param map_mgr sims1.server.map_mgr
---@param server sims1.server
local function new(map_mgr, server)
	---@class sims1.server.map 
	---@field id number 地图id
	---@field tpl_id string 模板id
	---@field npcs npc[] 地图上npc列表
	---@field regions sims1.server.map<int, sims1.server.region> 区域列表
	local api = {
		npcs = {}, 
		regions = {},
	}

	--- 初始化地图
	function api.init(uid, tpl_id)
		api.id = uid
		api.tpl_id = tpl_id
		local map_data = server.loader.map_list.get_by_id(tpl_id)
		assert(map_data.path)
		local map_handler = server.loader.map_data.get_data_handler(map_data.path)

		for _, region in ipairs(map_handler.data.regions) do 
			for _, layer in ipairs(region.layers) do 
				for gridId, grid in pairs(layer.grids) do 
					local y = layer.height + (grid.height or 0)
					local x, z = map_handler.grid_id_to_grid_pos(gridId)
					local regionId = api.world_pos_to_region_id(x, y, z)
					local region = api.get_or_create_region(regionId)
					region.add_grid(x, y, z, grid)
				end
			end
		end
		--common.lib.dump(api.regions)
	end

	--- 加入地图
	---@param npc sims1.server.npc 
	function api.on_login(npc)
		npc.map_id = api.id
		npc.pos_x = 0;
		npc.pos_y = 0;
		npc.pos_z = 0;
		npc.region_id = api.world_pos_to_region_id(npc.pos_x, npc.pos_y, npc.pos_z)
	end 

	--- 离开地图
	---@param npc sims1.server.npc
	function api.on_logout(npc)
		npc.map_id = 0
	end

	--- 世界坐标转换为区域id
	function api.world_pos_to_region_id(pos_x, pos_y, pos_z)
		local x = math.floor(pos_x / 10) 
		local y = math.floor(pos_y / 10) 
		local z = math.floor(pos_z / 10) 
		--return string.format("%s_%s_%s", x, y, z)
		return string.format("%s_%s", x, z)
	end

	---@return sims1.server.region
	function api.get_or_create_region(regionId)
		local region = api.regions[regionId] 
		if not region then 
			region = require 'service.server.map.region'.new(api)
			region.id = regionId
			region.init()
			api.regions[regionId] = region
		end 
		return region
	end

	---@return sims1.server.region
	function api.get_region(regionId)
		return api.regions[regionId]
	end

	---@param npc sims1.server.npc 
	function api.get_sync_regions(npc)
		local rets = {}
		for region_id, v in pairs(api.regions) do 
			rets[region_id] = v.get_sync_grids()
		end
		return rets
	end

	return api
end

return {new = new}