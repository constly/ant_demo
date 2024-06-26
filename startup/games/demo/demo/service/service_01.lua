ServiceWorld = ...
local ltask = require "ltask"
local S = {}
local is_pause = false

-- 这里处于一个独立的虚拟机中
-- require "core.startup"

--[[
1. 这里由core/core_05.lua 调用过来
2. 用于演示如何创建service以及互相通信
--]]

local update = function()
	print("[service_01] update", os.time())
end

local quit

-- fork一个子线程来运行服务
ltask.fork(function ()
	while not quit do
		if not is_pause then
			update()
		end
		-- 100 表示 1秒
		ltask.sleep(100)
	end
	ltask.wakeup(quit)
end)

-- 暴露接口，供其他service调用
function S.send_event(eventName, arg)
	print("send_event", eventName, arg)

	-- 调回主服务
	ltask.send(ServiceWorld, "rpc_notify_core_05", "你在给我发事件！")
end

function S.pause()
	is_pause = true;
end 

function S.continue()
	is_pause = false;
end

function S.quit()
	print("quit")
	-- 由于上面每0.1秒执行一次，这里有可能卡0.1秒，也许需要改为fork一个子线程来执行
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

return S;