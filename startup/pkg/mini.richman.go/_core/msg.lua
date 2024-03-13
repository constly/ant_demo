--------------------------------------------------------------
--- 房间消息定义 和 通用协议注册
--------------------------------------------------------------
local api = {tb_s2c = {}, tb_rpc = {}} 		---@class mrg.msg

api.client = nil 				---@type mrg.client_room
api.server = nil 				---@type mrg.server_room

--- 客户端全是rpc
api.rpc_login = 1					-- 登录
api.rpc_exit = 2					-- 退出房间
api.rpc_room_begin = 3				-- 房间战斗开始
api.rpc_ping = 4

--- 服务器全是主动通知 
api.s2c_room_members = 1			-- 通知房间成员列表
api.s2c_kick = 3;					-- 通知踢人
api.s2c_entry_room = 4;				-- 通知进入房间
api.s2c_ping = 5

local reg_rpc
local reg_s2c

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
end

--- 初始化
function api.init(isClient)
	api.clear();
	reg_rpc()
	if isClient then
		reg_s2c()
	end
end

--- 注册rpc
reg_rpc = function()
	local client = api.client
	local server = api.server

	-- 登录
	api.reg_rpc(api.rpc_login, 
		function(client_fd, tbParam)  	-- 服务器执行
			local player = server.players.add_member(client_fd, false)
			server.refresh_members()
			return {id = player.id}
		end, 
		function(tbParam)				--- 服务器返回后，客户端执行
			if tbParam and tbParam.id then
				local player = client.players.find_by_id(tbParam.id)
				if player then 
					player.is_self = true
					client.local_player = player
				end
			end
		end)

	-- 退出房间
	api.reg_rpc(api.rpc_exit, 
		function(client_fd, tbParam)
			server.players.remove_member(client_fd)
			server.refresh_members() 
			return {ok = true}
		end,
		function(tbParam)
			if tbParam and tbParam.ok then 
				client.close()
			end
		end)

	-- ping
	api.reg_rpc(api.rpc_ping, 
		function(client_fd, tbParam)
			print("[rpc_ping] recv client ping", client_fd, tbParam.v)
			return {ret = "succ"}
		end,
		function(tbParam)
			print("recv rpc ping", tbParam.ret)
		end)
end

--- 注册s2c
reg_s2c = function()
	local client = api.client

	-- 通知房间成员列表
	api.reg_s2c(api.s2c_room_members, function(tbParam)
		client.players.set_members(tbParam)
		local player = client.players.find_by_id(tbParam.id)
		if player then player.is_self = true end
	end)

	-- ping
	api.reg_s2c(api.s2c_ping, function(tbParam)
		print("ping", tbParam.v)
	end)

	-- 通知踢人
	api.reg_s2c(api.s2c_kick, function(tbParam)
		if tbParam.id == client.self_player_id then 
			client.close()
		end 
	end)

	-- 通知进入房间
	api.reg_s2c(api.s2c_entry_room, function(tbParam)
		
	end)
end

return api