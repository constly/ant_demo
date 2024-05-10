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

local task_queue = {}
local function add_task(f, ...)
	local tail = task_queue.t
	if tail then
		task_queue[tail] = table.pack( f, ... )
		task_queue.t = tail + 1
	else
		-- empty
		task_queue.h = 1
		task_queue.t = 1
		f(...)
		while task_queue.h < task_queue.t do
			local h = task_queue.h
			local task = task_queue[h]
			task_queue[h] = nil
			task_queue.h = h + 1
			task[1](table.unpack(task, 2, task.n))			
		end
		task_queue.h = nil
		task_queue.t = nil
	end
end

local S = {}

--[[
这里使用了一个队列，保证前一个响应执行完毕后才会执行后面的
之所以这样，是因为：函数中有io操作时，会导致函数挂起，从而出现并行执行现象
具体问题描述见这里：https://github.com/ejoy/ant/discussions/138
--]]
local QUEUE = setmetatable({}, {
	__newindex = function(_, name, f)
		S[name] = function(...)
			add_task(f, ...)
		end
	end
})


---@class sims.server.start.params
---@field scene string 启动场景
---@field save_root string 存档根目录
---@field ip string 服务器监听id地址
---@field port number 服务器监听端口号
---@field ip_type string ip类型
---@field room_name string 房间名字
---@param tbParam sims.server.start.params
function QUEUE.start(tbParam)
	server.start_param = tbParam
	server.save_mgr.saved_root = tbParam.save_root
	server.init()
	server.room.init_server(tbParam.ip, tbParam.port)
	local tb = server.player_mgr.add_player(0, 0, "local_player")
	tb.is_leader = true 
	tb.is_local = true
end

function QUEUE.dispatch_netmsg(cmd, tbParams)
	server.room.dispatch_rpc(0, cmd, tbParams or {})
end 

function QUEUE.shutdown()
	server.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

ltask.fork(update)

return S;