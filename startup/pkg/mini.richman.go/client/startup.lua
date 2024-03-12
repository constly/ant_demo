local ecs = ...
local system 		= ecs.system "startup"
local dep 			= require 'dep'
local ImGui 		= dep.ImGui
local statemachine 	= require 'client.state_machine'  ---@type mini.richman.go.view.state_machine

function system.init()
	print("system.init")
end 

function system.post_init()
	print("system.post_init")
end

function system.init_world()
	print("system.init_world")
	statemachine.init(false, RichmanMgr.is_listen_player)
end

function system.exit()
	print("system.exit")
	statemachine.reset()
end


function system.data_changed()
	ImGui.SetNextWindowPos(10, 10)
	ImGui.SetNextWindowSize(100, 60);
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		if ImGui.ButtonEx(" 返 回 ") then 
			--local main = require 'main' ---@type mini.richman.go.main
			--main.leave()
			RichmanMgr.exitCB()
		end
	end 
	ImGui.End()
end