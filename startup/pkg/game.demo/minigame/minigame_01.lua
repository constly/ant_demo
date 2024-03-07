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
		ImGui.Text("大富翁go")
		if ImGui.ButtonEx(" 开 始 ") then 
			richman.entry({
				leaveCB = function()
					local window = import_package "ant.window"
					window.reboot({feature = { "game.demo|gameplay" }})
				end
			});
		end
	end 
	ImGui.End()
end