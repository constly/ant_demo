------------------------------------------------------
--- center 
--- 服务器数据中心，其他服务都来这里存取数据
--- 本服务还负责处理存档/读档
------------------------------------------------------
local ltask = require "ltask"

---@type sims.s.center
local center = require 'center'.new()

local S = {}

---@param tbParam sims.server.start.params
function S.start(tbParam)
	center.start(tbParam)
end

function S.dispatch_rpc(client_fd, player_id, cmd, tbParam)
	local msg = center.msg
	local p = center.player_mgr.find_by_id(player_id)
	if not p and cmd ~= msg.rpc_gate_to_center_login then 
		return log.warn("can not find player, player_id = ", player_id)
	end
	local rpc = msg.tb_rpc[cmd]
	if not rpc or rpc.type ~= msg.type_center then 
		return log.error("消息转发异常, 不应该发到center处理, cmd = ", cmd)
	end
	local ret = rpc.server(p, tbParam)
	if ret then
		ltask.send(center.tbParam.addrGate, "dispatch_rpc_rsp", client_fd, cmd, ret)
	end 
end

function S.shutdown()
	center.shutdown()
    ltask.quit()
end

--- 通知玩家网络连接fd已经关闭
function S.notify_player_offline(fd)
	center.player_mgr.notify_player_offline(fd)
end

---@param totalTime number 服务器运行总时间
---@param deltaSecond number 本帧间隔，单位秒
function S.update(totalTime, deltaSecond)
	center.service_mgr.update(totalTime, deltaSecond)
end

---@param tbParam sims.server.npc.create_param
---@return sims.s.server.npc
function S.apply_create_npc(tbParam)
	local npc = center.npc_mgr.create_npc(tbParam)
	return npc.get_sync_server()
end

---@param world_id number 
---@param tbParam sims.server.world.save_data
function S.save_server_world(world_id, tbParam)
	for id, v in pairs(tbParam.npcs) do 
		local npc = center.npc_mgr.get_npc_by_id(id)
		if npc then 
			npc.pos_x = v.pos_x
			npc.pos_y = v.pos_y
			npc.pos_z = v.pos_z
		end
	end
end

return S;