local ltask = require "ltask"
---@type sims.core
local core = import_package 'sims.core'

local function new()
	---@class sims.server 
	---@field serviceGoap number goap规划服务地址
	---@field servicePathfinder number 寻路服务地址
	---@field map_mgr sims.server.map_mgr 地图管理
	---@field room sims.server_room
	---@field msg sims.msg
	local api = {}

	api.msg = core.new_msg()
	api.loader = core.new_loader()
	api.player_mgr = require 'room.player_mgr'.new(api) 
	api.room = require 'room.server_room'.new(api)  
	api.map_mgr = require 'map.map_mgr'.new(api)
	api.npc_mgr = require 'npc.server_npc_mgr'.new(api)

	function api.init()
		api.msg.init(false, api)
		api.serviceGoap = ltask.spawn("sims.s.goap|entry", ltask.self())
		api.servicePathfinder = ltask.spawn("sims.s.path|entry", ltask.self())
		ltask.send(api.serviceGoap, "init", {"/pkg/sims.res/goap/test.goap"})	
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
		api.npc_mgr.restart()
		api.map_mgr.restart()
		api.player_mgr.reset_players_npc()
		api.room.notify_restart()
	end 

	function api.tick(delta_time)
		api.room.tick()
	end

	return api
end

return {new = new}