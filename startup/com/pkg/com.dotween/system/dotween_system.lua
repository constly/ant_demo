local ecs = ...
local system = ecs.system "dotween_system"
local mgr = require "main"

function system.data_changed()
	local datas = mgr.get_datas()
	for i, data in ipairs(datas) do 
		
	end
end