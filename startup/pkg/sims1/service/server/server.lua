local ltask = require "ltask"

local function new()
	---@class sims1.server 
	---@field serviceGoap number goap规划服务地址
	---@field servicePathfinder number 寻路服务地址
	---@field map_mgr sims1.server.map_mgr 地图管理
	---@field room sims1.server_room
	---@field msg sims1.msg
	local api = {}

	api.msg = require 'core.msg.msg'.new()
	api.loader = require 'core.loader.loader'.new()			
	api.player_mgr = require 'service.server.room.player_mgr'.new(api) 
	api.room = require 'service.server.room.server_room'.new(api)  
	api.map_mgr = require 'service.server.map.map_mgr'.new(api)
	api.npc_mgr = require 'service.server.npc.server_npc_mgr'.new(api)

	function api.init()
		api.msg.init(false, api)
		api.serviceGoap = ltask.spawn("sims1|goap/entry", ltask.self())
		api.servicePathfinder = ltask.spawn("sims1|pathfinder/entry", ltask.self())
		ltask.send(api.serviceGoap, "init", {"/pkg/sims1.res/goap/test.goap"})	
		api.restart()
	end 

	function api.shutdown()
		if api.serviceGoap then 
			ltask.send(api.serviceGoap, "shutdown")
			api.serviceGoap = nil
		end 
		if api.servicePathfinder then 
			ltask.send(api.servicePathfinder, "shutdown")
			api.servicePathfinder = nil
		end
	end

	-- 重启服务器(socket连接保留)
	function api.restart()
		api.loader.restart()
		api.map_mgr.restart()
		api.npc_mgr.restart()
		api.player_mgr.reset_players_npc()
		api.room.notify_restart()
	end 

	function api.tick(delta_time)
		api.room.tick()
	end

	return api
end

return {new = new}