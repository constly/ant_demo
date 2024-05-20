--------------------------------------------------------------
--- 客户端/服务器通信 协议注册
--------------------------------------------------------------

---@class sims.msg.rpc_define
---@field type number 消息类型
---@field server function 服务器执行回调
---@field client function 客户端执行回调

local function new()
	---@class sims.msg
	---@field tb_s2c table
	---@field tb_rpc map<number, sims.msg.rpc_define>
	local api = {tb_s2c = {}, tb_rpc = {}} 		

	api.client = nil 				---@type sims.client
	api.server = nil 				---@type sims.server
	api.gate = nil					---@type sims.s.gate
	api.center = nil				---@type sims.s.center

	api.type_client = 1
	api.type_gate = 2
	api.type_center = 3
	api.type_old_server = 9

	--- 客户端到gate
	api.rpc_client_to_gate_login 				= 1101   	-- 客户端登录到gate
	
	--- 客户端到center
	api.rpc_client_to_center_set_move_dir 		= 2101		-- 客户端请求设置移动方向

	--- gate到center
	api.rpc_gate_to_center_login 				= 3101		-- gate通知有玩家登录

	--- center到客户端
	api.center_to_client_notify_players 		= 4101

	


	--- 客户端全是rpc（服务器可以不返回）
	api.rpc_login = 1					-- 登录
	api.rpc_logout = 2					-- 登出
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

	function api.clear()
		reg_rpc = nil
		reg_s2c = nil
		api.client = nil
		api.server = nil
		api.gate = nil
		api.center = nil
	end

	--- 注册rpc
	function api.reg_rpc(type, cmd, server_cb, client_cb)
		assert(not api.tb_rpc[cmd])
		api.tb_rpc[cmd] = {type = type, server = server_cb, client = client_cb}
	end
	
	function api.reg_gate_rpc(cmd, server_cb, client_cb) api.reg_rpc(api.type_gate, cmd, server_cb, client_cb) end
	function api.reg_center_rpc(cmd, server_cb, client_cb) api.reg_rpc(api.type_center, cmd, server_cb, client_cb) end

	--- 注册协议
	function api.reg_s2c(cmd, cb)
		assert(not api.tb_s2c[cmd])
		api.tb_s2c[cmd] = cb
	end

	--- 初始化
	function api.init(type, outer)
		require 'msg.msg_npc'.new(api)
		require 'msg.client_to_gate'.new(api)
		require 'msg.client_to_center'.new(api)

		if type == api.type_client then
			api.client = outer
			reg_s2c()

		elseif type == api.type_gate then 
			api.gate = outer

		elseif type == api.type_center then
			api.center = outer

		elseif type == api.type_old_server then
			api.server = outer
		end
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