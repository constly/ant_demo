--------------------------------------------------------------
--- 局域网房间列表
--------------------------------------------------------------
local ltask = require "ltask"
local ly_net = require 'ly.net'
local api = {}  ---@class ly.room.match.room_list
local quit 
local port = 17668
local client
local server

-- 每帧更新，获取局域网内广播信息
local function loop()
	while not quit do 
		local ip, port, msg = client:receive()
		if ip then 
			print(string.format("ip:  %s \nport: %d \nmsg: %s", ip, port, msg))
		end
		ltask.sleep(0)
	end	
	client:close()
	client = nil
end

--- 初始化
function api.init()
	if client then return end 
	quit = false
	client = ly_net.CreateBroadCast()
	if not client:init_client(port) then 
		log.warn("failed to create broadcast client, error = " .. client:last_error())
	end
	ltask.fork(loop)
end 

--- 退出时
function api.exit()
	quit = true
	if server then 
		server:close()
		server = nil
	end 
end 

--- 得到房间列表
function api.get_rooms()
	return {}
end 

--- 发送房间信息到局域网
function api.send_room_data(msg)
	if not server then 
		server = ly_net.CreateBroadCast()
		if not server:init_server("255.255.255.255", port) then 
			log.warn("failed to create broadcast server, error = " .. server:last_error())
		end
	end 
	server:send(msg) 
end

return api