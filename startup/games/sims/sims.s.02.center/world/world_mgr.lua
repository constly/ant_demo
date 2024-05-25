------------------------------------------------------
--- 服务器world管理
------------------------------------------------------

local world_alloc = require 'world.world'.new

---@param center sims.s.center
local function new(center)
	---@class sims.server.world_mgr
	local api = {}
	local next_id = 0;
	api.worlds = {}  		---@type map<number, sims.center.world>

	function api.shutdown()
		for i, world in pairs(api.worlds) do 
			world.destroy()
		end
		api.worlds = {}
		next_id = 0
	end

	function api.to_save_data()
		local tbData = {}
		return tbData
	end

	---@param worlds sims.save.worlds[]
	function api.load_from_save(worlds)
		api.shutdown()
		api.create_world(1)
	end

	function api.create_world(tpl_id)
		next_id = next_id + 1
		local world = world_alloc(center)
		world.init(next_id, tpl_id)
		api.worlds[world.id] = world
		return world
	end

	---@return sims.center.world
	function api.get_world(world_id)
		return api.worlds[world_id]
	end

	return api
end

return {new = new}