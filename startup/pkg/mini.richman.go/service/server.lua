------------------------------------------------------
--- 服务器入口
------------------------------------------------------
ServiceWindow = ...

local ltask = require "ltask"
local room = require 'service.room.server_room'  ---@type mrg.server_room
local quit 

local function Update()
	room.init_server()
	while not quit do 
		room.tick()
		--print("logic update", os.clock())
		ltask.sleep(5)
	end
	ltask.wakeup(quit)
end

local S = {}

function S.shutdown()
    quit = {}
    ltask.wait(quit)
end

function S.dispatch_netmsg(cmd, tbParams)
	print("logic dispatch_netmsg", cmd ,tbParams)
end 


ltask.fork(Update)

return S;