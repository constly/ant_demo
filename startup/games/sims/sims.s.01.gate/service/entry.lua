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

--- 通知玩家所在world_id
function S.notify_player_world_id(player_id, world_id)
	local p = gate.player_mgr.find_by_id(player_id)
	if p then 
		p.world_id = world_id
	end
end

--- 通知world的server服务地址
function S.notify_world_server_id(world_id, server_id)
	gate.world_2_server[world_id] = server_id
end

--- 通知world的导航服务地址
function S.notify_world_nav_id(world_id, nav_id)
	gate.world_2_nav[world_id] = nav_id
end

function S.send_to_player(player_id, cmd, tbParam)
	local p = gate.player_mgr.find_by_id(player_id)
	gate.net_mgr.send_to_client(p.fd, cmd, tbParam)
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