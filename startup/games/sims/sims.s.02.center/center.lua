---@type sims.core
local core = import_package 'sims.core'
local ltask = require "ltask"

local function new()
	---@class sims.s.center
	---@field tbParam sims.server.start.params
	---@field addrGate number gate地址
	local api = {}

	api.world_mgr = require 'world.world_mgr'.new(api)		---@type sims.server.world_mgr
	api.player_mgr = require 'player.player_mgr'.new(api); 	---@type sims.server.player_mgr
	api.npc_mgr = require 'npc.server_npc_mgr'.new(api)		---@type sims.server.npc_mgr
	api.save_mgr = require 'save.save_mgr'.new(api)			---@type sims.server.save_mgr
	api.service_mgr = require 'service.service_mgr'.new(api)---@type sims.s.service_mgr
	
	api.msg = core.new_msg()
	api.loader = core.new_loader()
	api.define = core.define

	---@param tbParam sims.server.start.params
	function api.start(tbParam)
		api.addrGate = tbParam.addrGate
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
		tbParam.path_map_list = api.tbParam.scene
		api.loader.restart(tbParam)
	end

	function api.restart_after()
		api.player_mgr.notify_restart()
	end

	function api.shutdown()
		api.world_mgr.shutdown()
		api.service_mgr.shutdown()
		print("close sims center")
	end

	function api.send_to_gate(...)
		ltask.send(api.addrGate, ...)
	end

	return api
end

return {new = new}