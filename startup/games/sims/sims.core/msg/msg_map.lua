---@type ly.common
local common = import_package 'ly.common'

---@param api sims.msg
local function new(api)
	
	api.reg_rpc(api.rpc_apply_map, 
		function(player, tbParam, fd)  	
			local npc = player.npc  ---@type sims.server.npc
			local map = api.server.map_mgr.find_map_by_id(npc.map_id)
			local regions = map.get_sync_regions(npc)
			return {map_id = npc.map_id, map_tpl_id = map.tpl_id, regions = regions}
		end, 
		function(tbParam)				
			api.client.map.load_region(tbParam.map_id, tbParam.map_tpl_id, tbParam.regions)
		end)
	
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
end

return {new = new}