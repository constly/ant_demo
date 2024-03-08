local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "minigame_02_system",
    category        = mgr.type_minigame,
    name            = "01_大富翁Go",
    file            = "minigame/minigame_01.lua",
	ok 				= false
}
local system 		= mgr.create_system(tbParam)
local ImGui     	= require "imgui"
local richman 		= import_package 'mini.richman.go' ---@type mini.richman.go.main

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		
		ImGui.SetCursorPos(200, 100)
		ImGui.BeginGroup()
		ImGui.Text("1. 青春版大富翁Go")
		ImGui.Text("2. 探索在Ant中进行联机开发")
		ImGui.Text("3. 只有运行时版本才能多开联机")
		ImGui.EndGroup()


		ImGui.SetCursorPos(200, 250)
		ImGui.BeginGroup()
		if ImGui.ButtonEx("单 机", 150, 60) then 
			richman.entry({
				leaveCB = function()
					local window = import_package "ant.window"
					window.reboot({feature = { "game.demo|gameplay" }})
				end
			});
		end
		
		ImGui.Dummy(10, 10)
		if ImGui.ButtonEx("局域网联机", 150, 60) then 
			richman.entry({
				leaveCB = function()
					local window = import_package "ant.window"
					window.reboot({feature = { "game.demo|gameplay" }})
				end
			});
		end
		ImGui.EndGroup()
		
	end 
	ImGui.End()
end