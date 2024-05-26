------------------------------------------------------
--- server
--- 一个server上可以多有个world
------------------------------------------------------
local ltask = require "ltask"
local server = require 'server'.new()  ---@type sims.s.server
local S = {}
local isFree = false

---@param tbParam sims.server.start.params
function S.start(tbParam)
	isFree = false
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
	assert(world, string.format("can not find world, id = %d", tbParam.world_id))
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
---@param world_id number 世界id
---@param list sims.s.server.npc[]
function S.notfiy_create_npc(world_id, list)
	local world = server.get_world(world_id)
	for i, v in ipairs(list) do 
		world.npc_mgr.create_npc(v)
	end
end

--- 每帧更新
function S.update(totalTime, deltaSecond)
	for i, w in pairs(server.worlds) do 
		w.npc_mgr.tick(totalTime, deltaSecond)
	end
end

function S.dispatch_rpc(client_fd, player_id, world_id, cmd, tbParam)
	if isFree then 
		log.error(string.format("rpc调用异常: server 已经被释放, id = %d", ltask.self()))
		return
	end
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

--- 保存world数据
function S.save()
	for i, w in pairs(server.worlds) do 
		w.save()
	end
end 

--- 清空所有数据，等待下次复用
function S.clear()
	for i, v in pairs(server.worlds) do 
		v.destroy()
	end
	server.worlds = {}
	isFree = true
end

return S;