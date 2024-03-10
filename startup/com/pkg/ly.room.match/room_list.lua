--------------------------------------------------------------
--- 局域网房间列表
--------------------------------------------------------------
local ly_net = require 'ly.net'
local common = import_package 'ly.common' ---@type ly.common.main
local quit 
local port = 17668
local client
local server
local tb_rooms = {} ---@type ly.room.match.room_list_one[]

--------------------------------------------------------------
--- 房间相关接口
--------------------------------------------------------------
---@return ly.room.match.room_list_one
local function find_or_add_room(ip)
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

local function remove_room(ip)
	for i, v in ipairs(tb_rooms) do 
		if v.ip == ip then 
			table.remove(tb_rooms, i)
			break
		end
	end
	print("remove room", ip)
end

--------------------------------------------------------------
--- api 接口
--------------------------------------------------------------
local api = {}  ---@class ly.room.match.room_list
--- 初始化
function api.init()
	if client then return end 
	quit = false
	client = ly_net.CreateBroadCast()
	if not client:init_client(port) then 
		log.warn("failed to create broadcast client, error = " .. client:last_error())
	end
end 

--- 退出时
function api.exit()
	quit = true
	tb_rooms = {}
	if server then 
		server:close()
		server = nil
	end 
	if client then 
		client:close()
		client = nil
	end 
end 

--- 更新局域网内房间列表
function api.tick()
	while client do 
		local ip, port, msg = client:receive()
		if ip then 
			if msg == "close" then
				remove_room(ip)
			else 
				local list = common.lib.split(msg, ";")
				local room = {}
				for i, v in ipairs(list) do 
					local arr = common.lib.split(v, ":");
					if #arr == 2 then 
						room[arr[1]] = arr[2] 
					end 
				end 
				room.update_time = os.clock()
				local tb = find_or_add_room(room.ip)
				for key, v in pairs(room) do 
					tb[key] = v
				end
			end
		else
			break; 
		end 
	end
end 

--- 得到房间列表
---@return ly.room.match.room_list_one[] 
function api.get_rooms()
	return tb_rooms
end 

--- 发送房间信息到局域网
function api.broadcast(msg)
	if not server then 
		server = ly_net.CreateBroadCast()
		if not server:init_server("255.255.255.255", port) then 
			log.warn("failed to create broadcast server, error = " .. server:last_error())
		end
	end 
	server:send(msg) 
end

return api