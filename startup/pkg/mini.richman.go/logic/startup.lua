------------------------------------------------------
--- 逻辑层入口
------------------------------------------------------

local dep = require 'dep' ---@type mini.richman.go.dep 
local ltask = dep.ltask
local quit 

local function Update()
	while not quit do 
		print("logic update", os.clock())
		ltask.sleep(5)
	end
	ltask.wakeup(quit)
end

local S = {}

function S.shutdown()
    quit = {}
    ltask.wait(quit)
end

function S.message_process(cmd, tbParams)

end 


ltask.fork(Update)

return S;