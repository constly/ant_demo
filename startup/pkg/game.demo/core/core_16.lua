local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_16_system",
    category        = mgr.type_core,
    name            = "16_声音",
    file            = "core/core_16.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w
local sound = import_package "game.sound"

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    if ImGui.Begin("wnd_debug", nil, ImGui.WindowFlags {"AlwaysAutoResize", "NoMove", "NoTitleBar"}) then
		-- "1. 2D声音，包括BGM和音效; \n2. 3D声音，可以指定声音距离摄像机的距离，有暂停/继续/中止等接口演示；\n3.音量调节"
		if ImGui.ButtonEx("播放声音1", 100) then 
			sound.play_sound("/pkg/game.res/sound/select.wav")
		end
		if ImGui.ButtonEx("播放声音2", 100) then 
			sound.play_sound("/pkg/game.res/sound/click.wav")
		end
	end
	ImGui.End()
end
