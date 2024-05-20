local ltask = require "ltask"

local function new()
	---@class sims.s.main
	---@field addrCenter number 数据中心地址
	---@field addrGate number gate地址
	local api = {}

	local function init()
		api.addrCenter = ltask.spawn("sims.s.02.center|entry", ltask.self())
		api.addrGate = ltask.spawn("sims.s.03.gate|entry", ltask.self())

		-- 处理npc移动
	--	api.addrMove = ltask.spawn("sims.s.04.move|entry", ltask.self())
	end

	---@param tbParam sims.server.start.params
	function api.start(tbParam)
		tbParam.addrCenter = api.addrCenter
		tbParam.addrGate = api.addrGate
		init()

		ltask.send(api.addrGate, "start", tbParam)
		ltask.send(api.addrCenter, "start", tbParam)
	end 

	function api.shutdown()
		ltask.call(api.addrGate, "shutdown")	
		ltask.call(api.addrCenter, "shutdown")	
		--ltask.call(api.addrMove, "shutdown")	
	end

	---@param totalTime number 服务器运行总时间
	---@param deltaSecond number 本帧间隔，单位秒
	function api.update(totalTime, deltaSecond)
		ltask.send(api.addrGate, "update", totalTime, deltaSecond)	
	end

	return api
end

return {new = new}