local ecs = ...
local system = ecs.system "init_system"
local dep = require 'dep'

function system.preinit()
	RichmanMgr = {}
	local map = dep.common.map
	print("init_system.preinit, open param is", map.tbParam, RichmanMgr)

	RichmanMgr.exitCB = function()
		dep.common.map.load({feature = {"game.demo|gameplay"}})
	end
end 

function system.exit()
	RichmanMgr = nil
end

