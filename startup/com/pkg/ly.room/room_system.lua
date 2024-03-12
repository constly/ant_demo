local ecs = ...
local system 	= ecs.system "room_system"
local ImGui 	= require 'imgui'
local common 	= import_package 'ly.common'	---@type ly.common.main
local show_type = 1
local room_list = require 'room_list' 			---@type ly.room.room_list
local mgr = require 'src.room_mgr'				---@type ly.room.room_mgr
local openParams

function system.preinit()
	local map = common.map
	openParams = map.tbParam
end

function system.init_world()
	room_list.init()
	mgr.init()
end

function system.exit()
	room_list.exit()
	print("exit room_system")
end 

function system.data_changed()
	if mgr.is_valid() then 
		mgr.tick()
	else
		show_type = 1
	end
	room_list.tick()

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
	common.imgui_utils.draw_text_center(openParams.name or "局域网联机")
	ImGui.SetCursorPos(x - 20, 5)
	if common.imgui_utils.draw_btn(" X ###btn_close", false, {size_x = 30, size_y = 30}) then 
		mgr.close()
		openParams.leaveCB()
	end

	ImGui.SetCursorPos(60, 80)
	ImGui.BeginChild("##child_1", x - 100, y - 180, ImGui.ChildFlags({}))
	do
		local x, y = ImGui.GetContentRegionAvail()
		local time = os.clock()
		for i, v in ipairs(room_list.get_rooms()) do 
			if time - v.update_time < 1 then
				ImGui.BeginGroup()
				ImGui.Text(tostring(i))
				ImGui.SameLineEx(50)
				ImGui.Text(string.format("%s:%s %s", v.ip, v.port, v.type))
				ImGui.SameLineEx(150)
				ImGui.Text(v.name or "")
				ImGui.SameLineEx(x - 80)
				if common.imgui_utils.draw_btn(" 加 入 ###btn_join" .. i, true) then 
					if mgr.client.init(v.ip, v.port) then 
						show_type = 2
					end
				end
				ImGui.EndGroup()
			end
		end
	end
	ImGui.EndChild()

	ImGui.SetCursorPos(x * 0.5 - 50, y - 50)
	if common.imgui_utils.draw_btn(" 创建房间 ", true, {size_x = 100, size_y = 40}) then 
		if mgr.server.init_server() then 
			show_type = 2
		end 
	end
end

function system.draw_room_data()
	local x, y = ImGui.GetContentRegionAvail()
	common.imgui_utils.draw_text_center(openParams.name or "局域网联机")

	ImGui.SetCursorPos(60, 80)
	ImGui.BeginChild("##child_1", x - 100, y - 180, ImGui.ChildFlags({"Border"}))
	do 
		local x, y = ImGui.GetContentRegionAvail()
		for i, member in ipairs(mgr.players.tb_members) do 
			ImGui.BeginGroup()
			ImGui.Text(tostring(i))
			ImGui.SameLineEx(50)
			ImGui.Text(member.name)
			ImGui.EndGroup()
		end
	end 
	ImGui.EndChild()

	if mgr.server.is_open() then 
		ImGui.SetCursorPos(x * 0.5 - 120, y - 50)
		if common.imgui_utils.draw_btn("解散房间", false, {size_x = 100, size_y = 40}) then 
			show_type = 1
			mgr.close()
		end
		ImGui.SameLine()
		if common.imgui_utils.draw_btn(" 开 始 ", true, {size_x = 100, size_y = 40}) then 
			mgr.client.apply_begin() 
		end
	else 
		ImGui.SetCursorPos(x * 0.5 - 50, y - 50)
		if common.imgui_utils.draw_btn(" 退 出 ", true, {size_x = 100, size_y = 40}) then 
			show_type = 1
			mgr.client.apply_exit()
		end
	end
end