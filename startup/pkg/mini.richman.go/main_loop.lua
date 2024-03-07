local ecs = ...
local system 	= ecs.system "data_system"
local dep 		= require 'dep'
local ImGui 	= dep.ImGui

function system.init_world()
	print("system.init_world")
end

function system.exit()
end

function system.data_changed()
	ImGui.SetNextWindowPos(10, 10)
	ImGui.SetNextWindowSize(100, 60);
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		if ImGui.ButtonEx(" 返回 ") then 
			local main = require 'main' ---@type mini.richman.go.main
			main.leave()
		end
	end 
	ImGui.End()
end

print("load main_loop")