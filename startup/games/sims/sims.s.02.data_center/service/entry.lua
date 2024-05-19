------------------------------------------------------
--- data_center 
--- 服务器数据中心，其他服务都来这里存取数据
--- 本服务还负责处理存档/读档
------------------------------------------------------
SServer = ...
local ltask = require "ltask"
local quit

---@type sims.s.data_center
local data_center = require 'data_center'.new()

local S = {}

---@param tbParam sims.server.start.params
function S.start(tbParam)
	data_center.start(tbParam)
end

function S.dispatch_rpc(client_fd, cmd, tbParam)
	local p = data_center.player_mgr.find_by_fd(client_fd)
	if not p then 
		log.warn("can not find player, fd = ", client_fd)
		return
	end
	local rpc = data_center.msg.tb_rpc[cmd]
	if not rpc or rpc.type ~= data_center.msg.type_data_center then 
		return
	end
	local ret = rpc.server(p, tbParam)
	if ret then
		ltask.send(data_center.tbParam.addrGate, "dispatch_rpc_rsp", client_fd, cmd, ret)
	end 
end

function S.shutdown()
	data_center.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

--- 通知玩家网络连接fd已经关闭
function S.notify_player_fd_close(fd)
	data_center.player_mgr.notify_fd_close(fd)
end


return S;