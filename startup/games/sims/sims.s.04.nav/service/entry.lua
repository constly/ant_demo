------------------------------------------------------
--- nav
--- 处理导航寻路
------------------------------------------------------
local ltask = require "ltask"
local nav = require 'nav'.new()  ---@type sims.s.nav
local S = {}
local isFree = false

---@param tbParam sims.server.start.params
function S.start(tbParam)
	isFree = false
	nav.start(tbParam)
end

function S.shutdown()
	nav.shutdown()
    ltask.quit()
end

---@param tbParam sims.server.create_world_params
function S.create_world(tbParam)
	nav.create_world(tbParam)
end

function S.destroy_world(world_id)
	nav.destroy_world(world_id)
end

---@param tbParam sims.server.login.param 登录参数
function S.login(tbParam)
	local world = nav.get_world(tbParam.world_id)
	assert(world, string.format("can not find world, id = %d", tbParam.world_id))
	return world.on_login(tbParam)
end

--- 每帧更新
function S.update(totalTime, deltaSecond)
	for i, w in pairs(nav.worlds) do 
		w.npc_mgr.tick(totalTime, deltaSecond)
	end
end

function S.dispatch_rpc(client_fd, player_id, world_id, cmd, tbParam)
	if isFree then 
		log.error(string.format("rpc调用异常: nav 已经被释放, id = %d", ltask.self()))
		return
	end
	local world = nav.get_world(world_id)
	local msg = world.msg
	local rpc = msg.tb_rpc[cmd]
	if not rpc or rpc.type ~= msg.type_nav then 
		return log.error("消息转发异常, 不应该发到nav处理, cmd = ", cmd)
	end
	local ret = rpc.server(player_id, tbParam)
	if ret then
		ltask.send(nav.addrGate, "dispatch_rpc_rsp", client_fd, cmd, ret)
	end 
end

--- 清空所有数据，等待下次复用
function S.clear()
	for i, v in pairs(server.worlds) do 
		v.destroy()
	end
	nav.worlds = {}
	isFree = true
end

return S;