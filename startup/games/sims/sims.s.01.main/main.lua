local ltask = require "ltask"

local function new()
	---@class sims.s.main
	---@field addrDataCenter number 数据中心地址
	---@field addrGate number gate地址
	local api = {}

	function api.start()
		api.addrDataCenter = ltask.spawn("sims.s.02.data_center|entry", ltask.self())
		api.addrGate = ltask.spawn("sims.s.03.gate|entry", ltask.self())
	end 

	function api.shutdown()
		ltask.call(api.addrGate, "shutdown")	
		ltask.call(api.addrDataCenter, "shutdown")	
	end

	---@param totalTime number 服务器运行总时间
	---@param deltaSecond number 本帧间隔，单位秒
	function api.update(totalTime, deltaSecond)

	end

	return api
end

return {new = new}