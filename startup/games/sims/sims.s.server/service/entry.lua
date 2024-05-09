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

---@class sims.server.start.params
---@field scene string 启动场景
---@field save_root string 存档根目录
---@field ip string 服务器监听id地址
---@field port number 服务器监听端口号
---@field ip_type string ip类型
---@field room_name string 房间名字
---@param tbParam sims.server.start.params
function S.start(tbParam)
	server.save_mgr.saved_root = tbParam.save_root

	server.init()
	server.room.init_server(tbParam.ip, tbParam.port)
	local tb = server.player_mgr.add_player(0, 0, "local_player")
	tb.is_leader = true 
	tb.is_local = true
	print("set_saved_root", server.save_mgr.saved_root)
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