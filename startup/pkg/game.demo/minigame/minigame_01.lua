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
local dep 			= require 'dep' 	---@type game.demo.dep
local ImGui     	= dep.ImGui
local map 			= dep.common.map

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
			map.load({feature = { "mini.richman.go|gameplay" }, is_standalone = true})
		end
		
		ImGui.Dummy(10, 10)
		if ImGui.ButtonEx("局域网联机\n(需使用运行时版本)", 200, 60) then 
			map.load({
				feature = { "ly.room" },
				name = "大富翁局域网联机",
				room_feature = {"mini.richman.go|gameplay" }, -- 匹配成功后 进入房间
				leaveCB = function()			-- 中断匹配时 回来
					map.load({feature = { "game.demo|gameplay" }})
				end
			})
		end
		ImGui.EndGroup()
		
	end 
	ImGui.End()
end