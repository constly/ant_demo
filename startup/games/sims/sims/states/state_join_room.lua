-----------------------------------------------------------------------
--- 加入房间
-----------------------------------------------------------------------

---@class ly.sims.room_list_one 局域网内广播的房间简略数据
---@field ip string 房间id 
---@field type string ip类型: IPv4 or IPv6
---@field port number 房间端口号
---@field name string 房间名 
---@field update_time number 最近更新时间

local ly_net = require 'ly.net'
local ImGui 		= require "imgui"

---@type ly.common
local common 		= import_package 'ly.common' 	




---@param s sims.client.state_machine
---@param client sims.client
local function new(s, client)
	local api = {} ---@type sims.client.state_machine.state_base 

	local broadcast_client
	local tb_rooms = {}  ---@type ly.sims.room_list_one[]

	function api.on_entry()
		if not broadcast_client then
			broadcast_client = ly_net.CreateBroadCast()
			if not broadcast_client:init_client(client.lan_broadcast_port) then 
				log.warn("failed to create broadcast client, error = " .. broadcast_client:last_error())
			end
		end
	end

	function api.on_destroy()
		broadcast_client = nil
	end

	function api.on_update()
		api.update_room_list()

		local viewport = ImGui.GetMainViewport();
		local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
		local width, height = 500, 300
		local top_x, top_y = (size_x - width) * 0.5, (size_y - height) * 0.5 - 50
		ImGui.SetNextWindowPos(top_x, top_y)
		ImGui.SetNextWindowSize(width, height);

		local window_flag = ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse"}
		local ret, open = ImGui.Begin("##window_body", true, window_flag) 
		if ret then 
			ImGui.Dummy(20, 5)
			common.imgui_utils.draw_text_center("加入房间")
			ImGui.SetCursorPos(20, 90)
			ImGui.BeginGroup()
			for idx, room in ipairs(tb_rooms) do 
				ImGui.Text(tostring(idx))
				ImGui.SameLineEx(30)
				ImGui.Text(room.ip)
				ImGui.SameLineEx(180)
				ImGui.SameLine()
				ImGui.Text(room.name)
				ImGui.SameLineEx(380)

				local label = string.format("加入##btn_join_%d", idx)
				if common.imgui_utils.draw_btn(label, true, {size_x = 60}) then 
					client.join_room(room.ip, room.port)
				end
				ImGui.Separator()
			end
			ImGui.EndGroup()
			ImGui.End()
		end
		
		if not open then
			s.goto_state(s.state_entry)
		end
	end

	function api.on_exit()
		tb_rooms = {}
	end

	function api.update_room_list()
		while broadcast_client do 
			local ip, port, msg = broadcast_client:receive()
			if ip then 
				if msg == "close" then
					api.remove_room(ip)
				else 
					local list = common.lib.split(msg, ";")
					---@type ly.sims.room_list_one
					local room = {}
					for i, v in ipairs(list) do 
						local arr = common.lib.split(v, "&");
						if #arr == 2 then 
							room[arr[1]] = arr[2] 
						end 
					end 
					room.update_time = os.clock()
					local tb = api.find_or_add_room(room.ip)
					for key, v in pairs(room) do 
						tb[key] = v
					end
				end
			else
				break; 
			end 
		end
	end

	function api.remove_room(ip)
		for i, v in ipairs(tb_rooms) do 
			if v.ip == ip then 
				table.remove(tb_rooms, i)
				break
			end
		end
		print("remove room", ip)
	end

	function api.find_or_add_room(ip)
		for i, v in ipairs(tb_rooms) do 
			if v.ip == ip then 
				return v
			end
		end
		local tb = {}
		tb.ip = ip
		table.insert(tb_rooms, tb)
		print("add room", ip)
		return tb
	end

	return api
end

return {new = new}