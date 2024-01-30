ServiceWorld = ...
local ltask = require "ltask"

local S = {}
local is_pause = false

-- 这里处于一个独立的虚拟机中
-- require "core.startup"

local update = function()
	print("[service_01] update", os.time())
end

-- fork一个子线程来运行服务
ltask.fork(function ()
	while true do
		if not is_pause then
			update()
		end
		-- 100 表示 1秒
		ltask.sleep(100)
	end
end)

-- 暴露接口，供其他service调用
function S.send_event(eventName, arg)
	print("send_event", eventName, arg)

	-- 调回主服务
	ltask.send(ServiceWorld, "rpc_notify_core_03", "你在给我发事件！")
end

function S.pause()
	is_pause = true;
end 

function S.continue()
	is_pause = false;
end

function S.quit()
	print("quit")
	ltask.quit()
end

return S;