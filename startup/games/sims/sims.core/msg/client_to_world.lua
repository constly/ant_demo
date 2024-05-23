---@type ly.common
local common = import_package 'ly.common'

---@param api sims.msg
local function new(api)

	---@class sims.msg.s2c_npc_move
	---@field id number npcId
	---@field speed number 速度
	---@field dir number[] 移动方向
	---@field pos number[] npc位置

	-- 通知npc移动
	api.reg_s2c(api.s2c_npc_move, function(tbParam)
		---@type sims.msg.s2c_npc_move
		local p = tbParam
		local npc = api.client.npc_mgr.get_npc_by_id(p.id)
		if not npc then 
			api.client.call_server(api.rpc_apply_npc_data, {id = p.id})
			return 
		end 

		if npc.is_ready then
			local world = api.client.world
			local e<close> = world:entity(npc.root, "comp_move:update")
			if e then
				---@type sims.msg.s2c_npc_move
				local s = e.comp_move.server 
				if not s then 
					s = {}
					e.comp_move.server = s
				end
				s.dir = p.dir
				s.pos = p.pos
				s.speed = p.speed
			end
		else 
			log.warn("npc is not ready", npc.id)
		end
	end)


	api.reg_world_rpc(api.rpc_set_move_dir, 
		function(player_id, tbParam)
			---@type sims.server_player
			local p = player
			p.move_dir = tbParam.dir
		end)


	-- 进入区域
	api.reg_world_rpc(api.rpc_apply_region, 
		function(player_id, tbParam)
			local regionId = tbParam.region_id
			local region = api.world.get_or_create_region(regionId)
			if region then 
				region.add_player(player_id)
				return {regionId = regionId, data = region.get_sync_data()}	
			end
			return {regionId = regionId}
		end, 
		function(tbParam)
			local region = api.client.client_world.get_region(tbParam.regionId)
			if region then 
				region.set_data(tbParam.data)
			else 
				api.client.call_server(api.client.msg.rpc_exit_region, {list = {tbParam.regionId}})
			end
		end)


	-- 退出区域
	api.reg_world_rpc(api.rpc_exit_region, 
		function(player_id, tbParam)
			for _, regionId in ipairs(tbParam.list) do 
				local region = api.world.get_region(regionId)
				if region then 
					region.remove_player(player_id)
				end
			end
		end)
end



return {new = new}