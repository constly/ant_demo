---@type sims.core
local core = import_package 'sims.core'

local function new()
	---@class sims.s.center
	---@field tbParam sims.server.start.params
	local api = {}

	api.world_mgr = require 'world.world_mgr'.new(api)		---@type sims.server.world_mgr
	api.player_mgr = require 'player.player_mgr'.new(api); 	---@type sims.server.player_mgr
	api.npc_mgr = require 'npc.server_npc_mgr'.new(api)		---@type sims.server.npc_mgr
	api.save_mgr = require 'save.save_mgr'.new(api)			---@type sims.server.save_mgr
	
	api.msg = core.new_msg()
	api.loader = core.new_loader()
	api.define = core.define

	-- 主world
	api.main_world = nil	---@type sims.server.world

	---@param tbParam sims.server.start.params
	function api.start(tbParam)
		api.save_mgr.saved_root = tbParam.save_root
		api.tbParam = tbParam
		api.msg.init(api.msg.type_center, api)
		api.restart_before()
		api.save_mgr.load_save_last()
		api.restart_after()
	end

	function api.restart_before()
		---@type sims.core.loader.param
		local tbParam = {}
		tbParam.path_map_list = api.start_param.scene
		api.loader.restart(tbParam)
	end

	function api.restart_after()
		api.room.notify_restart()
	end

	function api.restart()
		api.world_mgr.load_from_save()
		api.npc_mgr.load_from_save()
		api.player_mgr.load_from_save()
	end

	function api.shutdown()
	end

	return api
end

return {new = new}