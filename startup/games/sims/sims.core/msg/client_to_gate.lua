local ltask = require "ltask"

---@param api sims.msg
local function new(api)
	--- gate登录到center
	api.reg_center_rpc(api.rpc_gate_to_center_login, 	--- center执行
		function(player, tbParam)
			local player = player or api.center.player_mgr.add_player(tbParam.id, tbParam.guid) ---@type sims.s.server_player
			player.is_online = true

			local world = api.center.world_mgr.get_world(player.world_id)
			assert(world, string.format("登录到center失败, world_id = %s", player.world_id))
			world.on_login(player)

			local npc = player.npc 
			return {id = player.id, pos = {x = npc.pos_x, y = npc.pos_y, z = npc.pos_z}}
		end,
		function(tbParam)								--- 客户端执行
			local player = api.client.players.find_by_id(tbParam.id)
			if player then 
				player.is_self = true
				api.client.player_ctrl.local_player = player
			end
			api.client.restart(tbParam.pos)
		end
	)

	-- 客户端登录到gate
	api.reg_gate_rpc(api.rpc_login, 
		function(player, tbParam, fd)  	-- 服务器执行
			local player = api.gate.player_mgr.find_by_guid(tbParam.guid) ---@type sims.s.gate.player
			if not player then 
				player = api.gate.player_mgr.create(tbParam.guid, fd)
			else 
				api.gate.player_mgr.set_fd(tbParam.guid, fd)
			end
			ltask.send(api.gate.addrCenter, "dispatch_rpc", fd, player.id, api.rpc_gate_to_center_login, {id = player.id, guid = tbParam.guid})
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