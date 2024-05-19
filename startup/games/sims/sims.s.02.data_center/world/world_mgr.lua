------------------------------------------------------
--- 服务器world管理
------------------------------------------------------
---@param data_center sims.s.data_center
local function new(data_center)
	---@class sims.server.world_mgr
	local api = {}

	function api.to_save_data()
		
	end

	function api.load_from_save()

	end

	function api.create_world(world_id)
		local world = require 'world.world'.new(data_center)
	end

	return api
end

return {new = new}