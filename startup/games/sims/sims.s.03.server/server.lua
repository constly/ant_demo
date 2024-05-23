---@type sims.core
local core = import_package 'sims.core'
local ltask = require "ltask"

local function new()
	---@class sims.s.server
	---@field worlds map<number, sims.s.world.world>
	---@field npc_mgr sims.s.server.npc_mgr
	---@field addrGate number
	---@field addrCenter number
	local api = {worlds = {}}
	
	api.loader = core.new_loader()
	api.define = core.define
	api.npc_mgr = require 'npc.npc_mgr'.new(api)

	--- 这里的msg暂时是为了npc.lua中的move同步
	api.msg = core.new_msg()

	---@param tbParam sims.server.start.params
	function api.start(tbParam)
		api.addrGate = tbParam.addrGate
		api.addrCenter = tbParam.addrCenter

		---@type sims.core.loader.param
		local loaderParam = {}
		loaderParam.path_map_list = tbParam.scene
		api.loader.restart(loaderParam)
	end 

	--- 创建world
	---@param tbParam sims.server.create_world_params
	function api.create_world(tbParam)
		---@type sims.s.world.world
		local world = require 'world.world'.new(api)
		world.start(tbParam)
		api.worlds[tbParam.id] = world
	end 

	--- 销毁world
	function api.destroy_world(world_id)
		local world = api.worlds[world_id]
		if world then
			world.destroy()
			api.worlds[world_id] = nil
		end
	end

	---@return sims.s.world.world
	function api.get_world(world_id)
		return api.worlds[world_id]
	end

	function api.send_to_player(player_id, cmd, tbParam)
		ltask.send(api.addrGate, "send_to_player", player_id, cmd, tbParam)
	end

	function api.shutdown()

	end

	return api
end

return {new = new}