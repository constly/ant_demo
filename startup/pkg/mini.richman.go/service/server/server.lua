local ltask = require "ltask"

local function new()
	---@class server 
	---@field serviceGoap number goap规划服务地址
	---@field servicePathfinder number 寻路服务地址
	---@field map_mgr map_mgr 地图管理
	local api = {}

	function api.init()
		api.serviceGoap = ltask.spawn("mini.richman.go|goap/entry", ltask.self())
		api.servicePathfinder = ltask.spawn("mini.richman.go|pathfinder/entry", ltask.self())
		ltask.send(api.serviceGoap, "init", {"/pkg/mini.richman.res/goap/test.goap"})

		api.map_mgr = require 'service.server.map.map_mgr'.new(api)
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

	function api.tick(delta_time)
	end

	return api
end

return {new = new}