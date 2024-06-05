local ecs       = ...
local world     = ecs.world
local system 	= ecs.system "init_system"
local ImGui 	= require "imgui"

Screen_Width 	= world.args.width
Screen_Height 	= world.args.height

---@type test.bgfx.data_mgr
local data_mgr 	= require "data_mgr"

function system:init()
	local window = require "window"
    window.set_title("Ant Game Engine 学习记录 - bgfx_01_helloworld")
end 

function system:update()
	ImGui.SetNextWindowPos(50, 200, ImGui.Cond.FirstUseEver)
	ImGui.SetNextWindowSize(300, 200, ImGui.Cond.FirstUseEver);

	local window_flag = ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"}
	if ImGui.Begin("window_body", nil, window_flag) then 
		for i, v in ipairs(data_mgr.tbExamples) do 
			if ImGui.ButtonEx(v._name, 100) then 
				data_mgr.entry(v)
			end
		end
	end
	ImGui.End()
	
	data_mgr.update()
end