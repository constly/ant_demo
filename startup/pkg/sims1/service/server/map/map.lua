---@type ly.common.main
local common = import_package 'ly.common'
---@type ly.game_core
local game_core = import_package 'ly.game_core'

---@param map_mgr map_mgr
local function new(map_mgr)
	---@class map 
	---@field id number 地图id
	---@field npcs npc[] 地图上npc列表
	---@field regions map<int, region> 区域列表
	local api = {
		npcs = {}, 
		regions = {},
	}

	--- 初始化地图
	function api.init(uid, tpl_id)
		local path = "/pkg/sims1.res/goap/main_map.map"
		local datalist = common.file.load_datalist(path)
		local map_handler = game_core.create_map_handler()
		map_handler.init(datalist)

		for _, region in ipairs(map_handler.data.regions) do 
			for _, layer in ipairs(region.layers) do 
				for gridId, grid in pairs(layer.grids) do 
					local z = layer.height + (grid.height or 0)
					local x, y = map_handler.grid_id_to_grid_pos(gridId)
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
		return string.format("%s_%s", x, y, z)
	end

	---@return region
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

	return api
end

return {new = new}