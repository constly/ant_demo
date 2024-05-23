------------------------------------------------------
--- server
--- 一个server上可以多有个world
------------------------------------------------------
local ltask = require "ltask"
local server = require 'server'.new()  ---@type sims.s.server
local S = {}

---@param tbParam sims.server.start.params
function S.start(tbParam)
	server.start(tbParam)
end

function S.shutdown()
	server.shutdown()
    ltask.quit()
end

---@param tbParam sims.server.create_world_params
function S.create_world(tbParam)
	server.create_world(tbParam)
end

---@param tbParam sims.server.login.param 登录参数
function S.login(tbParam)
	local world = server.get_world(tbParam.world_id)
	return world.on_login(tbParam)
end

---@param player_id number 玩家id
function S.logout(world_id, player_id)
end

--- 得到world存档数据
function S.get_world_save_data(world_id)
	local world = server.get_world(world_id)
	return world and world.get_save_data() or nil
end

--- 通知创建npc
---@param list sims.s.server.npc[]
function S.notfiy_create_npc(list)
	for i, v in ipairs(list) do 
		server.npc_mgr.create_npc(v)
	end
end

--- 每帧更新
function S.update(totalTime, deltaSecond)
	server.npc_mgr.tick(totalTime, deltaSecond)
end

function S.dispatch_rpc(client_fd, player_id, world_id, cmd, tbParam)
	local world = server.get_world(world_id)
	local msg = world.msg
	local rpc = msg.tb_rpc[cmd]
	if not rpc or rpc.type ~= msg.type_world then 
		return log.error("消息转发异常, 不应该发到world处理, cmd = ", cmd)
	end
	local ret = rpc.server(player_id, tbParam)
	if ret then
		ltask.send(server.addrGate, "dispatch_rpc_rsp", client_fd, cmd, ret)
	end 
end

return S;