local ecs       = ...
local world     = ecs.world
local system 	= ecs.system "init_system"
local ImGui 	= require "imgui"
local timer 	= ecs.require "ant.timer|timer_system"

---@type ly.common
local common 	= import_package 'ly.common'

Screen_Width 	= world.args.width
Screen_Height 	= world.args.height

ContentStartX 	= 150
ContentStartY 	= 0
ContentSizeX 	= Screen_Width - ContentStartX
ContentSizeY	= Screen_Height - ContentStartY

---@type test.bgfx.data_mgr
local data_mgr 	= require "data_mgr"

function system:init()
	local window = require "window"
    window.set_title("Ant Game Engine 学习记录 - bgfx_01_helloworld")
end 

function system:update()
	ImGui.SetNextWindowPos(0, 0)
	ImGui.SetNextWindowSize(ContentStartX, Screen_Height);

	local window_flag = ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse", "NoTitleBar", "NoResize"}
	if ImGui.Begin("examples", nil, window_flag) then 
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
		for i, v in ipairs(data_mgr.tbExamples) do 
			if common.imgui_utils.draw_btn(v._name, v == data_mgr.Current, {size_x = ContentStartX - 15}) then
				data_mgr.entry(v)
			end
		end
		ImGui.PopStyleVar()
	end
	ImGui.End()
	
	local delta_time = timer.delta() * 0.001
	data_mgr.update(delta_time)
end