------------------------------------------------------
--- gate服务 
--- 用于管理与局域网内其他客户端的网络链接
------------------------------------------------------
SServer = ...
local ltask = require "ltask"
local ly_net = require 'ly.net'
---@type sims.core
local core = import_package 'sims.core'

local function new_gate()
	---@class sims.s.gate
	---@class addrDataCenter number 数据中心地址
	---@class addrClient number 本地客户端地址
	local api = {}

	api.player_mgr = require 'player_mgr'.new()			---@type sims.s.gate.player_mgr
	api.net_handler = require 'net_handler'.new(api)	---@type sims.s.gate.net_handler
	api.msg = core.new_msg()

	local broadcast
	local broadcast_msg

	---@param tbParam sims.server.start.params
	function api.start(tbParam)
		api.msg.init(api.msg.type_gate, api)

		api.addrDataCenter = tbParam.addrDataCenter
		api.addrClient = tbParam.client_fd
		api.net_handler.start(tbParam.ip, tbParam.port)

		assert(not broadcast)
		broadcast = ly_net.CreateBroadCast()
		if not broadcast:init_server("255.255.255.255", tbParam.lan_broadcast_port) then 
			log.warn("failed to create broadcast server, error = " .. broadcast:last_error())
		end
		broadcast_msg = string.format("port&%s;name&%s;ip&%s;type&%s", tbParam.port, tbParam.room_name, tbParam.ip, tbParam.ip_type)
	end

	function api.update()
		if broadcast then
			broadcast:send(broadcast_msg) 
		end
	end

	function api.shutdown()
		api.net_handler.close()
		if broadcast then
			broadcast:send("close");
			broadcast:close()
			broadcast = nil
		end
	end

	return api
end


local S = {}
local gate = new_gate()

---@param tbParam sims.server.start.params
function S.start(tbParam)
	gate.start(tbParam)
end

function S.update(totalTime, deltaSecond)
	gate.update()
end

function S.dispatch_rpc_rsp(client_fd, cmd, tbParam)
	gate.net_handler.dispatch_rpc_rsp(client_fd, cmd, tbParam)
end

function S.shutdown()
	gate.shutdown()
    ltask.quit()
end

return S;