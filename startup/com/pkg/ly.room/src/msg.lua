--------------------------------------------------------------
--- 房间消息定义 和 通用协议注册
--------------------------------------------------------------
local common = import_package 'ly.common'
local map = common.map ---@type ly.common.map
local players = require 'src.players'  		---@type ly.room.players
local api = {tb_s2c = {}, tb_rpc = {}} 		---@class ly.room.msg

api.client = nil 				---@type ly.room.room_client
api.server = nil 				---@type ly.room.room_server

api.is_local_player = false		---@type boolean 是不是本地玩家
api.local_player_id = 0;		---@type number 本地玩家id

--- 客户端全是rpc
api.rpc_login = 1					-- 登录
api.rpc_exit = 2					-- 退出房间
api.rpc_room_begin = 3				-- 房间战斗开始

--- 服务器全是主动通知 
api.s2c_room_members = 1			-- 通知房间成员列表
api.s2c_room_begin = 2				-- 通知房间开始
api.s2c_kick = 3;					-- 通知踢人
api.s2c_entry_room = 4;				-- 通知进入房间

local reg_common_rpc 
local reg_common_s2c

--- 注册rpc
function api.reg_rpc(cmd, server_cb, client_cb)
	assert(not api.tb_rpc[cmd])
	api.tb_rpc[cmd] = {server = server_cb, client = client_cb}
end

--- 注册协议
function api.reg_s2c(cmd, cb)
	assert(not api.tb_s2c[cmd])
	api.tb_s2c[cmd] = cb
end

--- 清空
function api.clear()
	api.tb_s2c = {}
	api.tb_rpc = {}
	api.is_local_player = false
	api.local_player_id = 0
end

--- 初始化
function api.init()
	api.clear();
	reg_common_rpc()
	reg_common_s2c()
end

--- 注册通用rpc
reg_common_rpc = function()
	-- 登录
	api.reg_rpc(api.rpc_login, 
		function(client_fd, tbParam)  	-- 服务器执行
			local player = players.add_member(client_fd, false)
			api.server.refresh_members()
			return {id = player.id}
		end, 
		function(tbParam)				--- 服务器返回后，客户端执行
			if tbParam and tbParam.id then
				api.local_player_id = tbParam.id
				local player = players.find_by_id(tbParam.id)
				if player then 
					player.is_self = true
				end
			end
		end)

	-- 退出房间
	api.reg_rpc(api.rpc_exit, 
		function(client_fd, tbParam)
			players.remove_member(client_fd)
			api.server.refresh_members() 
			return {ok = true}
		end,
		function(tbParam)
			if tbParam and tbParam.ok then 
				api.client.close()
			end
		end)

	-- 房间开始 
	api.reg_rpc(api.rpc_room_begin, 
		function(client_fd, tbParam)
			api.server.begin()
		end,
		function(tbParam)
		end)
end

--- 注册通用s2c，以下回调全在客户端执行
reg_common_s2c = function()
	-- 通知房间成员列表
	api.reg_s2c(api.s2c_room_members, function(tbParam)
		if not api.is_local_player then
			players.tb_members = tbParam
			local player = players.find_by_id(tbParam.id)
			if player then player.is_self = true end
		end
	end)

	-- 通知房间开始
	api.reg_s2c(api.s2c_room_begin, function(tbParam)
		if not api.is_local_player then
		end
	end)

	-- 通知踢人
	api.reg_s2c(api.s2c_kick, function(tbParam)
		if tbParam.id == api.local_player_id then 
			api.client.close()
		end 
	end)

	-- 通知进入房间
	api.reg_s2c(api.s2c_entry_room, function(tbParam)
		local mgr = require 'src.room_mgr'
		map.load({feature = tbParam.feature, room_mgr = mgr})
	end)
end 

return api