--------------------------------------------------------------
--- 客户端/服务器通信 协议注册
--------------------------------------------------------------

local function new()
	---@class sims.msg
	local api = {tb_s2c = {}, tb_rpc = {}} 		

	api.client = nil 				---@type sims.client
	api.server = nil 				---@type sims.server

	--- 客户端全是rpc（服务器可以不返回）
	api.rpc_login = 1					-- 登录
	api.rpc_exit = 2					-- 退出房间
	api.rpc_room_begin = 3				-- 房间战斗开始
	api.rpc_ping = 4
	api.rpc_restart = 6					-- 重启服务器
	api.rpc_set_move_dir = 7			-- 设置移动方向
	api.rpc_apply_region = 8			-- 请求获取区域数据
	api.rpc_exit_region = 9				-- 请求离开区域
	api.rpc_apply_npc_data = 11			-- 获取npc数据

	--- 服务器全是主动通知 
	api.s2c_room_members = 1			-- 通知房间成员列表
	api.s2c_kick = 3;					-- 通知踢人
	api.s2c_entry_room = 4;				-- 通知进入房间
	api.s2c_ping = 5
	api.s2c_restart = 6;				-- 通知重启
	api.s2c_npc_move = 7;				-- 通知npc移动
	api.s2c_test = 99;					-- 测试

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

	--- 初始化
	function api.init(isClient, outer)
		require 'msg.msg_npc'.new(api)
		require 'msg.msg_world'.new(api)

		if isClient then
			api.client = outer
			reg_rpc()
			reg_s2c()
		else 
			api.server = outer
			reg_rpc()
		end
	end

	--- 注册rpc
	reg_rpc = function()
		-- 登录
		api.reg_rpc(api.rpc_login, 
			function(player, tbParam, fd)  	-- 服务器执行
				player = api.server.player_mgr.find_by_guid(tbParam.guid)
				if player then 
					player.fd = fd
					player.is_online = true
					api.server.room.refresh_members()
					local npc = api.server.main_world.on_login(player)
					return {id = player.id, pos = {x = npc.pos_x, y = npc.pos_y, z = npc.pos_z}}
				end
				return {}
			end, 
			function(tbParam)				--- 客户端执行
				if tbParam.id then
					local player = api.client.players.find_by_id(tbParam.id)
					if player then 
						player.is_self = true
						api.client.player_ctrl.local_player = player
					end
					api.client.restart(tbParam.pos)
				else 
					assert(tbParam, "登录失败")
					api.client.room.need_exit = true
				end
			end)

		-- 退出房间
		api.reg_rpc(api.rpc_exit, 
			function(player, tbParam)
				api.server.player_mgr.remove_player(player.fd)
				api.server.room.refresh_members() 
				return {ok = true}
			end,
			function(tbParam)
				if tbParam and tbParam.ok then 
					api.client.room.close()
				end
			end)

		-- ping
		api.reg_rpc(api.rpc_ping, 
			function(player, tbParam)
				print("server recv client ping", tbParam.v)
				return {ret = "succ"}
			end,
			function(tbParam)
				print("client recv rpc ping", tbParam.ret)
			end)
	end

	--- 注册s2c
	reg_s2c = function()
		-- 通知房间成员列表
		api.reg_s2c(api.s2c_room_members, function(tbParam)
			api.client.players.set_members(tbParam)
		end)

		-- ping
		api.reg_s2c(api.s2c_ping, function(tbParam)
			print("client recv s2c ping", tbParam.v)
		end)

		-- 通知踢人
		api.reg_s2c(api.s2c_kick, function(tbParam)
			if tbParam.id == api.client.player_ctrl.local_player.id then 
				api.client.room.close()
			end 
		end)

		-- 通知进入房间
		api.reg_s2c(api.s2c_entry_room, function(tbParam)
			
		end)

		-- 通知重启客户端
		api.reg_s2c(api.s2c_restart, function(tbParam)
			api.client.restart(tbParam.pos)
		end)

		-- 
		api.reg_s2c(api.s2c_test, function(tbParam)
			print(tbParam.msg)
		end)
	end
	return api
end 

return {new = new}