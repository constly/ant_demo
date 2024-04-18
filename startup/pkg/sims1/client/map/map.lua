---@type ly.common
local common = import_package 'ly.common'
local math3d = require "math3d"

---@param sims1 sims1
local function new(sims1)
	---@class sims1.client.map 
	local api = {}

	---@param grids sims1.server.grid[]
	function api.load_region(map_id, region_id, grids)
		local ecs = sims1.ecs
		local world = ecs.world
		local iom = ecs.require "ant.objcontroller|obj_motion"
		for i, grid in ipairs(grids) do 
			world:create_instance {
				prefab = "/pkg/game.res/npc/cube/cube_green.glb/mesh.prefab",
				on_ready = function(e)
					local eid = e.tag['*'][1]
					local ee<close> = world:entity(eid)
					iom.set_position(ee, math3d.vector(grid.pos_x, grid.pos_y, grid.pos_z))
				end
			}
		end
		common.lib.dump(grids)
	end

	return api
end

return {new = new}