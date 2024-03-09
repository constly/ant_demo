------------------------------------------------------
--- 逻辑层入口
------------------------------------------------------

local ltask = require "ltask"
local quit 

local function Update()
	while not quit do 
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