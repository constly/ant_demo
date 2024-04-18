
---@param api sims1.msg
local function new(api)
	
	api.reg_rpc(api.rpc_apply_map, 
		function(player, tbParam, fd)  	
			--api.server.map_mgr.
			print("apply map")
			return {}
		end, 
		function(tbParam)				
			print("apply map rsp")
		end)


end

return {new = new}