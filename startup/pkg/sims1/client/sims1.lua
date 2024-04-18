local dep = require 'client.dep'
local ltask = require "ltask"
local map = dep.common.map

local function new()
	---@class sims1
	---@field msg sims1.msg
	---@field is_listen_player boolean 是不是聆听玩家
	---@field serviceId number 服务器地址，只有聆听玩家才有这个值
	local api = {}
	api.msg 			= require 'core.msg'.new()  					---@type sims1.msg
	api.room 			= require 'client.room.client_room'.new(api)
	api.statemachine 	= require 'client.state_machine'.new(api)  		---@type sims1.client.state_machine

	local S
	local function init()
		api.msg.client = api.room

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

		local tbParam = map.tbParam or {is_standalone = true}
		api.is_listen_player = tbParam.is_listen_player or tbParam.is_standalone
		if api.is_listen_player then 
			api.serviceId = ltask.spawn("sims1|server/entry", ltask.self())
			api.msg.init(true)
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

	init()
	return api
end

return {new = new}