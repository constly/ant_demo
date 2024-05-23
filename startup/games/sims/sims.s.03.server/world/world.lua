---@type sims.core
local core = import_package 'sims.core'
local ltask = require "ltask"
local region_alloc = require 'world.region'.new

---@param server sims.s.server
local function new(server)
	---@class sims.s.world.world
	---@field id number
	---@field tpl_id number
	---@field regions map<number, sims.server.region> 区域列表
	local api = {classes = {}, regions = {}}

	api.msg = core.new_msg()

	function api.get_save_data()
		local data = {}
		return data
	end

	---@param tbParam sims.server.create_world_params
	function api.start(tbParam)
		api.msg.init(api.msg.type_world, api)

		local tpl_id = tbParam.tpl_id
		api.classes = {}
		api.regions = {}
		
		---@param map_data sims.file_map_list.line
		local function load_map(map_data)
			local map_handler = server.loader.map_data.get_data_handler(map_data.path)
			local path_grid_def = map_handler.data.setting.grid_def
			for _, layer in ipairs(map_handler.data.region.layers) do 
				for gridId, grid in pairs(layer.grids) do 
					local def = server.loader.map_grid_def.get_grid_def(path_grid_def, grid.tpl)
					if def then
						local x, z = map_handler.grid_id_to_grid_pos(gridId)
						---@type sims.server.region
						local region
						local y = math.floor(layer.height)
						x, y, z = server.define.grid_pos_to_world_pos(x, y, z)
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
						
							local ret = ltask.call(server.addrCenter, "apply_create_npc", params)
							local npc = server.npc_mgr.create_npc(ret)
							local regionId = server.define.world_pos_to_region_id(npc.pos_x, npc.pos_y, npc.pos_z)
							region = api.get_or_create_region(regionId)
							region.add_npc(npc)
						else
							local regionId = server.define.world_pos_to_region_id(x, y, z)
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

		for id, map_data in pairs(server.loader.map_list.data) do 
			if map_data.world == tpl_id then
				load_map(map_data)
			end
		end	
	end 

	function api.destroy()
		print("destroy sims world")
	end

	---@param params sims.server.login.param
	function api.on_login(params)
		local npc = server.npc_mgr.get_npc(params.npc_id)
		assert(npc)
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
		local region_id = server.define.world_pos_to_region_id(npc.pos_x, npc.pos_y, npc.pos_z)
		local region = api.get_region(region_id)
		assert(region)
		region.add_npc(npc)
		if npc.player_id and npc.player_id > 0 then
			region.add_player(npc.player_id)
		end
		return {pos_x = npc.pos_x, pos_y = npc.pos_y, pos_z = npc.pos_z}
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
			region = region_alloc(api, server)
			region.id = regionId
			local x, y, z = server.define.region_id_to_world_pos(regionId)
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