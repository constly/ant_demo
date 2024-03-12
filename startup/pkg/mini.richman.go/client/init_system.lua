local ecs = ...
local system = ecs.system "init_system"
local ltask = require "ltask"
local dep = require 'dep'

function system.preinit()
	RichmanMgr = {}
	local map = dep.common.map
	print("init_system.preinit, open param is", map.tbParam, RichmanMgr)

	RichmanMgr.exitCB = function()
		dep.common.map.load({feature = {"game.demo|gameplay"}})
	end

	RichmanMgr.is_listen_player = map.tbParam.is_listen_player or map.tbParam.is_standalone
	if RichmanMgr.is_listen_player then -- 只有 listen 玩家才有服务器
		RichmanMgr.serviceId = ltask.uniqueservice "mini.richman.go|server"
	end
	RichmanMgr.call_server = function(cmd, tbParam)
		if RichmanMgr.serviceId then
			ltask.send(RichmanMgr.serviceId, "dispatch_netmsg", cmd, tbParam)
		else 
		end
	end
end 

function system.exit()
	if RichmanMgr.serviceId then
		ltask.kill(RichmanMgr.serviceId)
	end
	RichmanMgr = nil
end

