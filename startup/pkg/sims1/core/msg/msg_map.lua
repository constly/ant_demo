---@type ly.common
local common = import_package 'ly.common'

---@param api sims1.msg
local function new(api)
	
	api.reg_rpc(api.rpc_apply_map, 
		function(player, tbParam, fd)  	
			local npc = player.npc  ---@type sims1.server.npc
			local map = api.server.map_mgr.find_map_by_id(npc.map_id)
			local regions = map.get_sync_regions(npc)
			return {map_id = npc.map_id, map_tpl_id = map.tpl_id, regions = regions}
		end, 
		function(tbParam)				
			api.client.map.load_region(tbParam.map_id, tbParam.map_tpl_id, tbParam.regions)
		end)
	
	api.reg_rpc(api.rpc_restart, 
		function(player, tbParam, fd)
			api.server.restart()
		end)

end

return {new = new}