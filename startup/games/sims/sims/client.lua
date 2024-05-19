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
	api.editor 			= require 'editor.editor'.new(api)		---@type sims.client.editor
	api.room 			= require 'room.client_room'.new(api)
	api.statemachine 	= require 'states.machine'.new(api)  		
	api.npc_mgr			= require 'npc.client_npc_mgr'.new(api)
	api.players 		= require 'player.client_players'.new(api)
	api.player_ctrl 	= require 'player.player_ctrl'.new(api)
	api.client_world 	= require 'world.client_world'.new(api)
	api.saved_root		= "";	-- 存档根目录
	api.is_listen_player = false
	api.create_room_param = {}	---@type sims.server.start.params
	api.lan_broadcast_port = 17669  -- 局域网广播ip

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
		api.msg.init(api.msg.type_client, api)

		---@type ly.mods.param
		local tbParam = {}
		tbParam.root = common.path_def.mod_root .. "/sims"
		game_core.init_mod(tbParam)
	end 
	
	function api.start()
		api.editor.init()
		api.statemachine.init()
	end

	function api.shutdown()
		api.statemachine.shutdown()
		S.exec_richman_client_rpc = nil
		S.exec_richman_client_s2c = nil
		api.destroy_room()
		api.editor.exit()
	end

	--- 退出场景
	function api.exitCB()
		map.load({feature = {"entry"}, pre = "sims"})
	end

	--- 销毁房间
	function api.destroy_room()
		if api.serviceId then
			ltask.send(api.serviceId, "shutdown")
			api.serviceId = nil
		end
		api.is_listen_player = false
		api.room.close()
		api.reset_world()
	end

	--- 创建房间
	---@param scene_path string 启动场景路径
	---@param scene sims.client.create_room.scene 场景详情
	function api.create_room(scene_path, scene)
		api.destroy_room()
		api.serviceId = ltask.spawn("sims.s.server|entry", ltask.self())
		local package_handler = game_core.create_package_handler(common.path_def.project_root)
		local root_path = __ANT_RUNTIME__ and common.path_def.cache_root or package_handler.get_pkg_path("sims.res")
		assert(root_path, "编辑器下走sims.res包, 运行时走cache目录")
		api.saved_root = tostring(root_path) .. "/saved/"
		
		---@type sims.server.start.params
		local tbParam = {}
		tbParam.save_root = api.saved_root
		tbParam.scene = scene_path
		tbParam.ip = common.net.get_lan_ipv4()
		tbParam.port = 9876
		tbParam.ip_type = "IPv4"
		tbParam.room_name = string.format("%s - %s", scene.key, scene.name)
		tbParam.leader_guid = common.user_data.get_guid()
		tbParam.lan_broadcast_port = api.lan_broadcast_port
		api.create_room_param = tbParam
		api.is_listen_player = true
		ltask.send(api.serviceId, "start", tbParam)
		api.call_server(api.msg.rpc_login, {guid = tbParam.leader_guid})
		api.statemachine.goto_state(api.statemachine.state_room_running)
	end

	--- 加入房间
	function api.join_room(ip, port)
		api.destroy_room()
		if api.room.init(ip, port) then 
			local guid = common.user_data.get_guid()
			api.room.apply_login(guid)
			api.statemachine.goto_state(api.statemachine.state_room_running)
		end
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

	--- 重置整个世界
	function api.reset_world()
		api.tick_timer.reset()
		api.time_timer.reset()
		api.npc_mgr.reset()
		api.player_ctrl.reset()
		api.client_world.reset()
	end

	--- 重启整个世界
	---@param pos vec3 出生位置
	function api.restart(pos)
		api.reset_world()
		
		---@type sims.core.loader.param
		local tbParam = {}
		tbParam.path_map_list = api.create_room_param.scene
		api.loader.restart(tbParam)

		api.player_ctrl.restart(pos)
		api.client_world.restart()
	end

	init()
	return api
end

return {new = new}