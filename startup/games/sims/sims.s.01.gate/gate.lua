local ltask = require "ltask"
local ly_net = require 'ly.net'

---@type sims.core
local core = import_package 'sims.core'

local function new()
	---@class sims.s.gate
	---@field addrCenter number 数据中心地址
	---@field addrClient number 客户端地址
	local api = {}

	api.player_mgr = require 'net.player_mgr'.new()			---@type sims.s.gate.player_mgr
	api.net_mgr = require 'net.net_mgr'.new(api)			---@type sims.s.net_mgr
	api.msg = core.new_msg()
	api.world_2_server = {}

	local broadcast
	local broadcast_msg

	---@param tbParam sims.server.start.params
	function api.start(tbParam)
		api.addrClient = tbParam.addrClient
		api.addrCenter = ltask.spawn("sims.s.02.center|entry", ltask.self())
		tbParam.addrCenter = api.addrCenter
		tbParam.addrGate = ltask.self()
		ltask.call(api.addrCenter, "start", tbParam)

		api.msg.init(api.msg.type_gate, api)
		api.net_mgr.start(tbParam.ip, tbParam.port)
		local tb = api.player_mgr.create(tbParam.leader_guid, 0)
		tb.is_leader = true 
		tb.is_local = true
		ltask.send(api.addrCenter, "dispatch_rpc", 0, tb.id, api.rpc_gate_to_center_login, {id = tb.id, guid = tb.guid})

		assert(not broadcast)
		broadcast = ly_net.CreateBroadCast()
		if not broadcast:init_server("255.255.255.255", tbParam.lan_broadcast_port) then 
			log.warn("failed to create broadcast server, error = " .. broadcast:last_error())
		end
		broadcast_msg = string.format("port&%s;name&%s;ip&%s;type&%s", tbParam.port, tbParam.room_name, tbParam.ip, tbParam.ip_type)
	end 

	function api.shutdown()
		api.net_mgr.close()
		if broadcast then
			broadcast:send("close");
			broadcast:close()
			broadcast = nil
		end
		ltask.send(api.addrCenter, "shutdown")	
		print("close sims gate")
	end

	---@param totalTime number 服务器运行总时间
	---@param deltaSecond number 本帧间隔，单位秒
	function api.update(totalTime, deltaSecond)
		if not api.addrCenter or not broadcast then return end 

		broadcast:send(broadcast_msg) 
		ltask.send(api.addrCenter, "update", totalTime, deltaSecond)	
	end

	return api
end

return {new = new}