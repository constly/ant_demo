
---@param api sims.msg
local function new(api)
	-- 登录
	api.reg_gate_rpc(api.rpc_login, 
		function(player, tbParam, fd)  	-- 服务器执行
			player = api.server.player_mgr.find_by_guid(tbParam.guid)
			if not player then 
				player = api.server.player_mgr.add_player(fd, tbParam.guid)
			end
			if player then 
				player.fd = fd
				player.is_online = true
				api.server.room.refresh_members()
				api.server.main_world.on_login(player)
				local npc = player.npc 
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
		end
	)

	-- 登出
	api.reg_gate_rpc(api.rpc_logout, 
		function(player, tbParam)
			api.server.player_mgr.remove_player(player.fd)
			api.server.room.refresh_members() 
			return {ok = true}
		end,
		function(tbParam)
			if tbParam and tbParam.ok then 
				api.client.room.close()
			end
		end
	)
end

return {new = new}