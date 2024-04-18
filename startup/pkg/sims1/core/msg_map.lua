---@type ly.common
local common = import_package 'ly.common'

---@param api sims1.msg
local function new(api)
	
	api.reg_rpc(api.rpc_apply_map, 
		function(player, tbParam, fd)  	
			local npc = player.npc  ---@type sims1.server.npc
			local map = api.server.map_mgr.find_map_by_id(npc.map_id)
			local region = map.get_region(npc.region_id)
			local grids = region.get_sync_grids()
			return {grids = grids, map_id = npc.map_id, region_id = npc.region_id}
		end, 
		function(tbParam)				
			api.client.map.load_region(tbParam.map_id, tbParam.region_id, tbParam.grids)
		end)


end

return {new = new}