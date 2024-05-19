------------------------------------------------------
--- 服务器主服务
------------------------------------------------------
SServer = ...

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
	tbParam.client_fd = SServer
	main.start(tbParam)
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