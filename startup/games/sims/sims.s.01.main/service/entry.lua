------------------------------------------------------
--- 服务器主服务
------------------------------------------------------
local addrClient = ...

---@type sims.s.main
local main = require 'main'.new()
local ltask = require "ltask"
local quit

local function update()
	local time = os.clock()
	local interval<const> = 0.05
	while not quit do 		
		local cur = os.clock()
		main.update(cur, cur - time)
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

--- 启动服务器
---@param tbParam sims.server.start.params
function S.start(tbParam)
	tbParam.addrClient = addrClient
	main.start(tbParam)
end

function S.dispatch_netmsg(cmd, tbParams)
	ltask.send(main.addrGate, "dispatch_rpc", 0, cmd, tbParams or {})
end 

--- 关闭服务器
function S.shutdown()
	quit = {}
	main.shutdown()
    ltask.wait(quit)
    ltask.quit()
end

ltask.fork(update)

return S;