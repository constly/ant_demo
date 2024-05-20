------------------------------------------------------
--- 服务器world
--- 一个world由多个region组成
------------------------------------------------------
---@param center sims.s.center
local function new(center)
	---@class sims.server.world
	---@field id number 唯一id
	---@field tpl_id number 模板id
	local api = {}

	function api.init(id, tpl_id)
		api.id = id
		api.tpl_id = id

		---@param map_data sims.file_map_list.line
		local function load_map(map_data)
			local map_handler = center.loader.map_data.get_data_handler(map_data.path)
			local path_grid_def = map_handler.data.setting.grid_def
			for _, layer in ipairs(map_handler.data.region.layers) do 
				for gridId, grid in pairs(layer.grids) do 
					local def = center.loader.map_grid_def.get_grid_def(path_grid_def, grid.tpl)
					if def then
						local x, z = map_handler.grid_id_to_grid_pos(gridId)
						---@type sims.server.region
						local region
						local y = math.floor(layer.height)
						x, y, z = center.define.grid_pos_to_world_pos(x, y, z)
						x = x + map_data.position[1] or 0
						y = y + map_data.position[2] or 0
						z = z + map_data.position[3] or 0
						if def.className == "npc" then 
							x = x + 0.5
							z = z + 0.5
							---@type sims.server.npc.create_param
							local params = {}
							params.tplId = def.param1
							params.world_id = api.id
							params.pos_x, params.pos_y, params.pos_z = x, y, z
						
							local npc = server.npc_mgr.create_npc(params)
							local regionId = define.world_pos_to_region_id(npc.pos_x, npc.pos_y, npc.pos_z)
							region = api.get_or_create_region(regionId)
							region.add_npc(npc)
						else
							local regionId = define.world_pos_to_region_id(x, y, z)
							region = api.get_or_create_region(regionId)
							local data = region.add_grid(x, y, z, grid)
							if def.className and def.className ~= "" then 
								local list = api.classes[def.className] or {}
								api.classes[def.className] = list
								table.insert(list, {x + 0.5, y, z + 0.5})
							end
						end
					end 
				end
			end
		end

		for id, map_data in pairs(center.loader.map_list.data) do 
			if map_data.world == tpl_id then
				load_map(map_data)
			end
		end	
	end

	---@param player sims.s.server_player
	---@param params sims.server.login.param
	function api.on_login(player, params)
		local npc = player.npc
		if npc.region then 
			return npc
		end
		local grid = api.get_first_gird_by_className("born")
		assert(grid)
		if params and params.pos_x then 
			npc.pos_x = params.pos_x
			npc.pos_y = params.pos_y
			npc.pos_z = params.pos_z
		else 
			npc.pos_x = grid[1];
			npc.pos_y = grid[2];
			npc.pos_z = grid[3];
		end
		local region_id = define.world_pos_to_region_id(npc.pos_x, npc.pos_y, npc.pos_z)
		local region = api.get_region(region_id)
		assert(region)
		region.add_npc(npc)
		region.add_player(player)
		return npc
	end

	--- 将格子id转换为格子坐标
	---@return number, number pos_x,pos_z
	function api.grid_id_to_grid_pos(gridId)
		local pos = string.find(gridId, "_")
		if pos then
			local x = string.sub(gridId, 1, pos - 1)
			local z = string.sub(gridId, pos + 1)
			return tonumber(x), tonumber(z)
		end
		return 0, 0
	end

	function api.get_region(regionId)
		return api.regions[regionId]
	end
	
	---@return sims.server.region
	function api.get_or_create_region(regionId)
		local region = api.regions[regionId] 
		if not region then 
			region = require 'world.region'.new(api, server)
			region.id = regionId
			local x, y, z = define.region_id_to_world_pos(regionId)
			local start = {x = x , y = y, z = z}
			region.init(regionId, start)
			api.regions[regionId] = region
		end 
		return region
	end

	---@return sims.server.grid
	function api.get_first_gird_by_className(className)
		local list = api.classes[className]
		return list and list[1]
	end

	return api
end

return {new = new}