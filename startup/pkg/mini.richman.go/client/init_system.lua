local ecs = ...
local system = ecs.system "init_system"
local ltask = require "ltask"
local dep = require 'dep'
local msg = require '_core.msg'
local room = require 'client.room.client_room'

function system.preinit()
	RichmanMgr = {}
	local map = dep.common.map
	local tbParam = map.tbParam
	print("init_system.preinit, open param is", tbParam, RichmanMgr)

	RichmanMgr.exitCB = function()
		dep.common.map.load({feature = {"game.demo|gameplay"}})
	end

	-- 扩展服务通信接口
	local S = ltask.dispatch {}
	function S.exec_richman_client_rpc(cmd, tbParam) 
		if RichmanMgr then 
			local tb = msg.tb_rpc[cmd]
			if tb then 
				tb.client(tbParam) 
			end
		end
	end

	RichmanMgr.is_listen_player = tbParam.is_listen_player or tbParam.is_standalone
	if RichmanMgr.is_listen_player then 
		RichmanMgr.serviceId = ltask.uniqueservice("mini.richman.go|server", ltask.self())
		if tbParam.is_standalone then
			ltask.send(RichmanMgr.serviceId, "init_standalone")
		else
			ltask.send(RichmanMgr.serviceId, "init_server", tbParam.ip, tbParam.port, tbParam.tb_members)
		end
	else 
		if room.init(tbParam.ip, tbParam.port) then 
			room.apply_login(tbParam.code)
		end
	end
	RichmanMgr.call_server = function(cmd, tbParam)
		if RichmanMgr.serviceId then
			ltask.send(RichmanMgr.serviceId, "dispatch_netmsg", cmd, tbParam)
		else 
			room.call_rpc(cmd, tbParam)
		end
	end
end 

function system.exit()
	if RichmanMgr.serviceId then
		ltask.kill(RichmanMgr.serviceId)
	end
	RichmanMgr = nil
end

function system.data_changed()
	RichmanMgr.call_server(msg.rpc_ping, {v = "2"})
end