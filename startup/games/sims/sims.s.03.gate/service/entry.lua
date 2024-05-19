------------------------------------------------------
--- gate服务 
--- 用于管理与局域网内其他客户端的网络链接
------------------------------------------------------
SServer = ...
local ltask = require "ltask"
local quit

---@type sims.s.gate
local gate_mgr = require 'gate_mgr'.new()

local function update()
	while not quit do 
		gate_mgr.update()
		ltask.sleep(1)
	end
	ltask.wakeup(quit)
end

local S = {}

---@class sims.s.gate.start_param
---@field ip string
---@field port number
---@field ip_type string
---@field name string 服务器名
---@field lan_broadcast_port number 局域网广播端口号

---@param tbParam sims.s.gate.start_param
function S.start(tbParam)
	gate_mgr.start(tbParam)
end

function S.shutdown()
	gate_mgr.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

ltask.fork(update)

return S;