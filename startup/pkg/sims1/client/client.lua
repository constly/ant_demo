local common = import_package 'ly.common'
local ltask = require "ltask"
local map = common.map

local function new(ecs)
	---@class sims1.client
	---@field ecs any
	---@field msg sims1.msg
	---@field is_listen_player boolean 是不是聆听玩家
	---@field serviceId number 服务器地址，只有聆听玩家才有这个值
	local api = {}
	api.msg 			= require 'core.msg.msg'.new()  				---@type sims1.msg
	api.loader 			= require 'core.loader.loader'.new()			---@type sims1.loader
	api.room 			= require 'client.room.client_room'.new(api)
	api.statemachine 	= require 'client.state_machine'.new(api)  		---@type sims1.client.state_machine
	api.map  			= require 'client.map.client_map'.new(api)		---@type sims1.client.map
	api.npc_mgr			= require 'client.npc.client_npc_mgr'.new(api)
	api.players 		= require 'client.player.client_players'.new()
	api.player_ctrl 	= require 'client.player.player_ctrl'.new(api)

	api.ecs 			= ecs

	local S
	local function init()
		-- 扩展服务通信接口
		S = ltask.dispatch {}
		function S.exec_richman_client_rpc(cmd, tbParam)  
			local tb = api.msg.tb_rpc[cmd]
			if tb then tb.client(tbParam) end
		end
		function S.exec_richman_client_s2c(cmd, tbParam)
			local tb = api.msg.tb_s2c[cmd]
			if tb then tb(tbParam) end
		end
		api.msg.init(true, api)
		local tbParam = map.tbParam or {is_standalone = true}
		api.is_listen_player = tbParam.is_listen_player or tbParam.is_standalone
		if api.is_listen_player then 
			api.serviceId = ltask.spawn("sims1|server/entry", ltask.self())
			if tbParam.is_standalone then
				ltask.send(api.serviceId, "init_standalone")
			else
				ltask.send(api.serviceId, "init_server", tbParam.ip, tbParam.port, tbParam.tb_members)
			end
		else 
			if api.room.init(tbParam.ip, tbParam.port) then 
				api.room.apply_login(tbParam.code)
			end
		end
	end 
	
	function api.start()
		api.statemachine.init(false, api.is_listen_player)
	end

	function api.shutdown()
		api.statemachine.reset()
		S.exec_richman_client_rpc = nil
		S.exec_richman_client_s2c = nil
		if api.serviceId then
			ltask.send(api.serviceId, "shutdown")
		end
	end

	--- 退出场景
	function api.exitCB()
		map.load({feature = {"game.demo|gameplay"}})
	end

	function api.call_server(cmd, tbParam)
		if api.serviceId then
			ltask.send(api.serviceId, "dispatch_netmsg", cmd, tbParam)
		else 
			api.room.call_rpc(cmd, tbParam)
		end
	end

	function api.update(delta_time)
		api.statemachine.update(delta_time)
	end

	function api.restart()
		api.loader.restart()
		api.npc_mgr.restart()
		api.map.cleanup()
		Sims1.call_server(api.msg.rpc_apply_map)
	end

	init()
	return api
end

return {new = new}