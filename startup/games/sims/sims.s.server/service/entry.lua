------------------------------------------------------
--- 服务器入口
------------------------------------------------------
ServiceWindow = ...

local ltask = require "ltask"
local server = require 'server'.new()
local quit

local function update()
	local time = os.clock()
	local interval<const> = 0.05
	while not quit do 		
		local cur = os.clock()
		server.clock_time = cur
		server.tick(cur - time)
		time = cur

		local delta = os.clock() - time
		if delta < interval then
			local wait = math.ceil((interval - delta) * 100)
			ltask.sleep(wait)
		end
	end
	ltask.wakeup(quit)
end

local S = {}

--- 设置存档根目录
function S.set_saved_root(saved_root)
	server.save_mgr.saved_root = saved_root
	print("set_saved_root", server.save_mgr.saved_root)
end

function S.init_standalone()
	server.init()
	local tb = server.player_mgr.add_player(0, 0, "local_player")
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
			local p = server.player_mgr.add_player(-1, false, "local_player")
			p.is_online = false
			p.code = v.code
		end
	end
end

function S.dispatch_netmsg(cmd, tbParams)
	--print("logic dispatch_netmsg", cmd ,tbParams)
	server.room.dispatch_rpc(0, cmd, tbParams or {})
end 

function S.shutdown()
	server.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

ltask.fork(update)

return S;