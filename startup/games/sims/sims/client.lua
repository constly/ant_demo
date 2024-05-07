---@type ly.common
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
	api.define 			= core.define
	api.time_timer		= common.new_time_timer()
	api.tick_timer		= common.new_tick_timer()
	api.room 			= require 'room.client_room'.new(api)
	api.statemachine 	= require 'state_machine'.new(api)  		
	api.npc_mgr			= require 'npc.client_npc_mgr'.new(api)
	api.players 		= require 'player.client_players'.new(api)
	api.player_ctrl 	= require 'player.player_ctrl'.new(api)
	api.client_world 	= require 'world.client_world'.new(api)
	api.saved_root		= "";	-- 存档根目录

	local tb_msg = {}
	local S
	local function init()
		-- 扩展服务通信接口
		S = ltask.dispatch {}
		function S.exec_richman_client_rpc(cmd, tbParam)  
			table.insert(tb_msg, {type = "rpc", cmd = cmd, param = tbParam})
		end
		function S.exec_richman_client_s2c(cmd, tbParam)
			table.insert(tb_msg, {type = "s2c", cmd = cmd, param = tbParam})
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
		-- 网络消息只能在ecs主循环中处理，否则会出现各种奇怪的问题（主要指涉及到引擎相关时，比如entity创建）
		if #tb_msg > 0 then
			for _, v in ipairs(tb_msg) do 
				if v.type == "rpc" then
					local tb = api.msg.tb_rpc[v.cmd]
					if tb then 
						tb.client(v.param) 
					end
				elseif v.type == "s2c" then
					local tb = api.msg.tb_s2c[v.cmd]
					if tb then 
						tb(v.param) 
					end
				end
			end
			tb_msg = {}
		end

		api.tick_timer.update()
		api.time_timer.update(delta_time)
		api.statemachine.update(delta_time)
		api.client_world.update_current_region()
	end

	---@param pos vec3 出生位置
	function api.restart(pos)
		api.tick_timer.reset()
		api.time_timer.reset()

		api.loader.restart()
		api.npc_mgr.restart()
		api.player_ctrl.restart(pos)
		api.client_world.restart()
	end

	init()
	return api
end

return {new = new}