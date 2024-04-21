---@type ly.common
local common = import_package 'ly.common'
local math3d = require "math3d"

---@param client sims.client
local function new(client)
	---@class sims.client.map 
	local api = {}

	local entities = {}
	local instances = {}

	function api.cleanup()
		local world = client.world
		for i, eid in ipairs(entities) do 
			world:remove_entity(eid)
		end
		for i, eid in ipairs(instances) do 
			world:remove_instance(eid)
		end
		entities = {}
		instances = {}
	end

	---@param regions map<string, sims.server.region.sync>
	function api.load_region(map_id, tpl_id, regions)
		local ecs = client.ecs
		local world = ecs.world
		local map_data = client.loader.map_list.get_by_id(tpl_id)
		assert(map_data.path)

		local path_grid_def = client.loader.map_data.get_grid_def(map_data.path)
		
		local iom = ecs.require "ant.objcontroller|obj_motion"
		for region_id, region in pairs(regions) do 
			for _, grid in ipairs(region.grids) do 
				local def = client.loader.map_grid_def.get_grid_def(path_grid_def, grid.tpl_id)
				if def.model then
					local instance = world:create_instance {
						prefab = def.model .. "/mesh.prefab",
						on_ready = function(e)
							local eid = e.tag['*'][1]
							local ee<close> = world:entity(eid)
							iom.set_position(ee, math3d.vector(grid.pos_x, grid.pos_y, grid.pos_z))
							iom.set_scale(ee, def.scale)
						end
					}
					table.insert(instances, instance)
				end
			end
			for _, npc in ipairs(region.npcs) do 
				client.npc_mgr.create_npc(npc)
			end
		end
		--common.lib.dump(regions)
	end

	return api
end

return {new = new}