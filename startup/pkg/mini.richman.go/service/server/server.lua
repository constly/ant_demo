------------------------------------------------------
--- 服务器入口
------------------------------------------------------
ServiceWindow = ...

print("ServiceWindow ", ServiceWindow)

local ltask = require "ltask"
local room = require 'service.server.room.server_room'  ---@type mrg.server_room
local quit

local serviceGoap
local servicePathfinder

local function init()
	serviceGoap = ltask.spawn("mini.richman.go|goap/goap", ltask.self())
	servicePathfinder = ltask.spawn("mini.richman.go|pathfinder/pathfinder", ltask.self())

	ltask.send(serviceGoap, "init", {"/pkg/mini.richman.res/goap/test.goap"})
end

local function Update()
	while not quit do 
		room.tick()
		--room.test()
		--print("logic update", os.clock())
		ltask.sleep(5)
	end
	ltask.wakeup(quit)
end

local S = {}

function S.init_standalone()
	room.msg.init()
	local tb = room.players.add_member(0, 0)
	tb.is_leader = true 
	tb.is_local = true
	init()
end

---@param ip string 服务器ip 
---@param port number 服务器端口号
---@param tb_members ly.room.member[] 房间成员列表
function S.init_server(ip, port, tb_members)
	room.init_server(ip, port)
	for i, v in ipairs(tb_members) do 
		if not v.is_leader then 
			local p = room.players.add_member(-1, false)
			p.is_online = false
			p.code = v.code
		end
	end
	init()
end

function S.dispatch_netmsg(cmd, tbParams)
	--print("logic dispatch_netmsg", cmd ,tbParams)
	room.dispatch_rpc(0, cmd, tbParams)
end 

function S.shutdown()
	if serviceGoap then 
		ltask.send(serviceGoap, "shutdown")
		serviceGoap = nil
	end 
	if servicePathfinder then 
		ltask.send(servicePathfinder, "shutdown")
		servicePathfinder = nil
	end
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end


ltask.fork(Update)

return S;