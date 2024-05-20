------------------------------------------------------
--- 服务器world管理
------------------------------------------------------
---@param center sims.s.center
local function new(center)
	---@class sims.server.world_mgr
	local api = {}
	local next_id = 0;
	api.worlds = {}  ---@type map<number, sims.server.world>

	function api.to_save_data()
		local tbData = {}
		return tbData
	end

	---@param worlds sims.save.worlds[]
	function api.load_from_save(worlds)
		center.main_world = api.create_world(1)
	end

	function api.create_world(tpl_id)
		next_id = next_id + 1
		local world = require 'world.world'.new(center)
		world.init(next_id, tpl_id)
		api.worlds[world.id] = world
		return world
	end

	function api.get_world(world_id)
		return api.worlds[world_id]
	end

	return api
end

return {new = new}