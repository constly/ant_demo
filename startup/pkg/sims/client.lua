local common = import_package 'ly.common'
local ltask = require "ltask"
local map = common.map
---@type sims.core
local core = import_package 'sims.core'

---@type ly.game_core
local game_core = import_package 'ly.game_core'

local function new(ecs)
	---@class sims.client
	---@field ecs any
	---@field world any
	---@field msg sims.msg
	---@field is_listen_player boolean 是不是聆听玩家
	---@field serviceId number 服务器地址，只有聆听玩家才有这个值
	local api = {}
	api.ecs 			= ecs
	api.world 			= ecs.world
	api.world.client 	= api
	api.msg 			= core.new_msg()
	api.loader 			= core.new_loader()
	api.room 			= require 'room.client_room'.new(api)
	api.statemachine 	= require 'state_machine'.new(api)  		
	api.map  			= require 'map.client_map'.new(api)		
	api.npc_mgr			= require 'npc.client_npc_mgr'.new(api)
	api.players 		= require 'player.client_players'.new(api)
	api.player_ctrl 	= require 'player.player_ctrl'.new(api)
	api.saved_root		= "";	-- 存档根目录

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
		local tbParam = map.tbParam or {}
		if not tbParam.is_online then 
			tbParam.is_standalone = true
		end
		api.is_listen_player = tbParam.is_listen_player or tbParam.is_standalone
		if api.is_listen_player then 
			api.serviceId = ltask.spawn("sims.s.server|entry", ltask.self())
			do 
				local package_handler = game_core.create_package_handler(common.path_def.project_root)
				local root_path = package_handler.get_pkg_path("sims.res")
				assert(root_path, "编辑器下走sims.res包, 运行时走cache目录")
				api.saved_root = tostring(root_path) .. "/saved/"
				ltask.send(api.serviceId, "set_saved_root", api.saved_root)
			end
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
		map.load({feature = {"entry"}, pre = "sims"})
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
		api.player_ctrl.restart()
		api.call_server(api.msg.rpc_apply_map)
	end

	init()
	return api
end

return {new = new}