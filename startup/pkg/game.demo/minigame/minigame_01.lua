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
local window 		= import_package "ant.window"

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		
		ImGui.SetCursorPos(200, 100)
		ImGui.BeginGroup()
		ImGui.Text("1. 魔改版大富翁Go")
		ImGui.Text("2. 探索使用Ant进行游戏开发")
		ImGui.Text("3. 探索联机开发框架")
		ImGui.EndGroup()


		ImGui.SetCursorPos(200, 250)
		ImGui.BeginGroup()
		if ImGui.ButtonEx("单 机", 200, 60) then 
			richman.entry({
				leaveCB = function()
					window.reboot({feature = { "game.demo|gameplay" }})
				end
			});
		end
		
		ImGui.Dummy(10, 10)
		if ImGui.ButtonEx("局域网联机\n(需使用运行时版本)", 200, 60) then 
			local room = import_package "ly.room" 		---@type ly.room.main 
			room.entry({
				name = "大富翁Go局域网联机",
				entryCB = function()		-- 匹配成功后 进入房间
					richman.entry({
						leaveCB = function()--- 房间退出时 回来
							window.reboot({feature = { "game.demo|gameplay" }})
						end
					});
				end,
				leaveCB = function()		-- 中断匹配时 回来
					window.reboot({feature = { "game.demo|gameplay" }})
				end
			})
		end
		ImGui.EndGroup()
		
	end 
	ImGui.End()
end