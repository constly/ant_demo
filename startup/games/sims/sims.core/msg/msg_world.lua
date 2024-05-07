---@type ly.common
local common = import_package 'ly.common'

---@param api sims.msg
local function new(api)
	
	-- api.reg_rpc(api.rpc_apply_map, 
	-- 	function(player, tbParam, fd)  	
	-- 		local npc = player.npc  ---@type sims.server.npc
	-- 		local map = api.server.map_mgr.find_map_by_id(npc.map_id)
	-- 		local regions = map.get_sync_regions(npc)
	-- 		return {map_id = npc.map_id, map_tpl_id = map.tpl_id, regions = regions}
	-- 	end, 
	-- 	function(tbParam)				
	-- 		api.client.map.load_region(tbParam.map_id, tbParam.map_tpl_id, tbParam.regions)
	-- 	end)
	
	api.reg_rpc(api.rpc_restart, 
		function(player, tbParam, fd)
			print("save type", tbParam.type, tbParam.save_id)
			if tbParam.type == "only_save" then 			-- 只存档
				return api.server.save_mgr.save()
			elseif tbParam.type == "cover" then				-- 覆盖存档
				return api.server.save_mgr.cover_save(tbParam.save_id)
			end
			api.server.restart_before()
			if tbParam.type == "load" then					-- 读档
				api.server.save_mgr.load_save(tbParam.save_id)	
			elseif tbParam.type == "new_save" then 			-- 新建存档
				api.server.save_mgr.new_save()
			elseif tbParam.type == "save_and_load" then 	-- 存档后马上读档（不写文件）
				api.server.save_mgr.save_and_load()
			elseif tbParam.type == "load_last" then 		-- 读取最近一次存档
				api.server.save_mgr.load_save_last()
			end
			api.server.restart_after()
		end)

	api.reg_rpc(api.rpc_set_move_dir, 
		function(player, tbParam)
			---@type sims.server_player
			local p = player
			p.move_dir = tbParam.dir
		end)

	-- 进入区域
	api.reg_rpc(api.rpc_apply_region, function(player, tbParam)
		local regionId = tbParam.region_id
		local region = api.server.main_world.get_or_create_region(regionId)
		if region then 
			region.add_player(player)
			return {regionId = regionId, data = region.get_sync_data()}	
		end
		return {regionId = regionId}
	end, function(tbParam)
		local region = api.client.client_world.get_region(tbParam.regionId)
		if region then 
			region.set_data(tbParam.data)
		else 
			api.client.call_server(api.client.msg.rpc_exit_region, {list = {tbParam.regionId}})
		end
	end)

	-- 退出区域
	api.reg_rpc(api.rpc_exit_region, function(player, tbParam)
		for _, regionId in ipairs(tbParam.list) do 
			local region = api.server.main_world.get_region(regionId)
			if region then 
				region.remove_player(player)
			end
		end
	end)

	
end

return {new = new}