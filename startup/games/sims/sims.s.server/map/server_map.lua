
---@param map_mgr sims.server.map_mgr
---@param server sims.server
local function new(map_mgr, server)
	---@class sims.server.map 
	---@field id number 地图id
	---@field tpl_id string 模板id
	---@field npcs npc[] 地图上npc列表
	---@field regions sims.server.map<int, sims.server.region> 区域列表
	---@field classes map<string, sims.server.grid[]> 按class分类
	local api = {
		npcs = {}, 
		regions = {},
		classes = {},
	}

	--- 初始化地图
	---@param map_save_data sims.save.map 地图存档数据
	---@param npc_data sims.save.npc_data npc存档数据
	function api.init(uid, tpl_id, map_save_data, npc_save_data)
		api.id = uid
		api.tpl_id = tpl_id
		local map_data = server.loader.map_list.get_by_id(tpl_id)
		assert(map_data.path)
		local map_handler = server.loader.map_data.get_data_handler(map_data.path)
		local path_grid_def = map_handler.data.setting.grid_def

		for _, layer in ipairs(map_handler.data.region.layers) do 
			for gridId, grid in pairs(layer.grids) do 
				local def = server.loader.map_grid_def.get_grid_def(path_grid_def, grid.tpl)
				if def then
					local y = layer.height + (grid.height or 0)
					local x, z = map_handler.grid_id_to_grid_pos(gridId)
					---@type sims.server.region
					local region
					if def.className == "npc" then 
						---@type sims.server.npc.create_param
						local params = {}
						params.tplId = def.param1
						params.mapId = uid

						local _gridId = string.format("%s_%s", uid, grid.id)
						local npc_data = npc_save_data and npc_save_data.map_npcs[_gridId]
						local id = nil
						if npc_data then
							id = npc_data.npc.id
							params.pos_x, params.pos_y, params.pos_z = npc_data.npc.pos_x, npc_data.npc.pos_y, npc_data.npc.pos_z
						else
							params.pos_x, params.pos_y, params.pos_z = x, y, z
						end
						local npc = server.npc_mgr.create_npc(params, id)
						npc.gridId = _gridId

						local regionId = api.world_pos_to_region_id(npc.pos_x, npc.pos_y, npc.pos_z)
						region = api.get_or_create_region(regionId)
						region.add_npc(npc)
					else
						local regionId = api.world_pos_to_region_id(x, y, z)
						region = api.get_or_create_region(regionId)
						local data = region.add_grid(x, y, z, grid)
						if def.className and def.className ~= "" then 
							local list = api.classes[def.className] or {}
							api.classes[def.className] = list
							table.insert(list, data)
						end
					end
				end
			end
		end
		--common.lib.dump(api.regions)
	end

	--- 加入地图
	---@param player sims.server_player 玩家对象
	function api.on_login(player)
		---@type sims.server.npc 
		local npc = player.npc
		local grid = api.get_first_gird_by_className("born") or {}
		npc.map_id = api.id
		npc.pos_x = grid.pos_x;
		npc.pos_y = grid.pos_y;
		npc.pos_z = grid.pos_z;
		npc.region_id = api.world_pos_to_region_id(npc.pos_x, npc.pos_y, npc.pos_z)
		local region = api.get_or_create_region(npc.region_id)
		region.add_npc(npc)
		region.add_player(player)
	end 

	--- 离开地图
	---@param npc sims.server.npc
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

	---@return sims.server.region
	function api.get_or_create_region(regionId)
		local region = api.regions[regionId] 
		if not region then 
			region = require 'map.region'.new(api, server)
			region.id = regionId
			region.init()
			api.regions[regionId] = region
		end 
		return region
	end

	---@return sims.server.region
	function api.get_region(regionId)
		return api.regions[regionId]
	end

	---@param npc sims.server.npc 
	function api.get_sync_regions(npc)
		local rets = {}
		for region_id, v in pairs(api.regions) do 
			rets[region_id] = v.get_sync_data()
		end
		return rets
	end

	---@return sims.server.grid
	function api.get_first_gird_by_className(className)
		local list = api.classes[className]
		return list and list[1]
	end

	--------------------------------------------------
	-- 每帧更新
	--------------------------------------------------
	function api.tick(delta_time)
		for region_id, region in pairs(api.regions) do 
			region.tick(delta_time)
		end
	end

	return api
end

return {new = new}