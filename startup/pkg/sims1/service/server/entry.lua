------------------------------------------------------
--- 服务器入口
------------------------------------------------------
ServiceWindow = ...

local ltask = require "ltask"
local server = require 'service.server.server'.new()
local quit

local function Update()
	while not quit do 		
		server.tick(0.001)
		--room.test()
		--print("logic update", os.clock())
		ltask.sleep(5)
	end
	ltask.wakeup(quit)
end

local S = {}

function S.init_standalone()
	server.init()
	local tb = server.room.player_mgr.add_member(0, 0)
	tb.is_leader = true 
	tb.is_local = true
end

---@param ip string 服务器ip 
---@param port number 服务器端口号
---@param tb_members ly.room.member[] 房间成员列表
function S.init_server(ip, port, tb_members)
	server.init()
	server.room.init_server(ip, port)
	for i, v in ipairs(tb_members) do 
		if not v.is_leader then 
			local p = server.room.player_mgr.add_member(-1, false)
			p.is_online = false
			p.code = v.code
		end
	end
end

function S.dispatch_netmsg(cmd, tbParams)
	--print("logic dispatch_netmsg", cmd ,tbParams)
	server.room.dispatch_rpc(0, cmd, tbParams)
end 

function S.shutdown()
	server.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end


ltask.fork(Update)

return S;