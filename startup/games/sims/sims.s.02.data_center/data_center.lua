---@type sims.core
local core = import_package 'sims.core'

local function new()
	---@class sims.s.data_center
	local api = {}

	api.world_mgr = require 'world.world_mgr'.new(api)		---@type sims.server.world_mgr
	api.player_mgr = require 'player.player_mgr'.new(api); 	---@type sims.server_player_mgr
	api.npc_mgr = require 'npc.server_npc_mgr'.new(api)		---@type sims.server.npc_mgr
	
	api.loader = core.new_loader()
	api.define = core.define

	-- 主world
	api.main_world = nil	---@type sims.server.world

	function api.start()
		
	end

	function api.shutdown()
	end

	return api
end

return {new = new}