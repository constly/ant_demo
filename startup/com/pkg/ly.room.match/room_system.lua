local ecs = ...
local system 	= ecs.system "room_system"
local ImGui 	= require 'imgui'
local net 		= import_package "ant.net"
local main 		= require 'main'  				---@type ly.room.match.main
local common 	= import_package 'ly.common'	---@type ly.common.main
local show_type = 1
local room_list = require 'room_list' 			---@type ly.room.match.room_list
local room_data = require 'room_data'			---@type ly.room.match.room_data

function system.init_world()
	room_list.init()
end

function system.exit()
	room_list.exit()
	room_data.close()
	print("exit room_system")
end 

function system.data_changed()
	local viewport = ImGui.GetMainViewport();
	local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
	local region_x, region_y = 800, 550

	ImGui.SetNextWindowPos((size_x - region_x) * 0.5, (size_y - region_y) * 0.5 - 50)
    ImGui.SetNextWindowSize(region_x, region_y)
    if ImGui.Begin("main", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar"}) then 
		if show_type == 1 then 
			system.draw_room_list()
		else 
			system.draw_room_data()
		end
	end
	ImGui.End()
end

function system.draw_room_list()
	local x, y = ImGui.GetContentRegionAvail()
	common.imgui_utils.draw_text_center(main.tbParam.name or "局域网联机")
	ImGui.SetCursorPos(x - 20, 5)
	if common.imgui_utils.draw_btn(" X ###btn_close", false, {size_x = 30, size_y = 30}) then 
		main.leave()
	end

	ImGui.SetCursorPos(60, 80)
	ImGui.BeginChild("##child_1", x - 100, y - 180, ImGui.ChildFlags({"Border"}))
	ImGui.EndChild()

	ImGui.SetCursorPos(x * 0.5 - 50, y - 50)
	if common.imgui_utils.draw_btn(" 创建房间 ", true, {size_x = 100, size_y = 40}) then 
		show_type = 2
		room_data.create()
	end
end

function system.draw_room_data()
	local x, y = ImGui.GetContentRegionAvail()
	common.imgui_utils.draw_text_center(main.tbParam.name or "局域网联机")


	ImGui.SetCursorPos(x * 0.5 - 50, y - 50)
	if common.imgui_utils.draw_btn(" 退 出 ", true, {size_x = 100, size_y = 40}) then 
		show_type = 1
		room_data.close()
	end
end