------------------------------------------------------
--- 服务器主服务
------------------------------------------------------
local addrClient = ...

---@type sims.s.gate
local gate = require 'gate'.new()
local ltask = require "ltask"
local quit

local function update()
	local time = os.clock()
	local interval<const> = 0.05
	while not quit do 		
		local cur = os.clock()
		gate.update(cur, cur - time)
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
	gate.start(tbParam)
end

--- 从其他service来的消息
function S.dispatch_rpc_rsp(client_fd, cmd, tbParam)
	gate.net_mgr.dispatch_rpc_rsp(client_fd, cmd, tbParam)
end

function S.dispatch_netmsg(cmd, tbParams)
	gate.net_mgr.dispatch_rpc(0, cmd, tbParams)
end 

--- 关闭服务器
function S.shutdown()
	gate.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

ltask.fork(update)

return S;