---@type ly.common
local common = import_package 'ly.common'

---@param api sims.msg
local function new(api)

	-- 请求寻路
	api.reg_nav_rpc(api.rpc_find_path, function(player_id, tbParam)
		return api.nav.find_path(tbParam)
	end, function(tbParam)
		print("client执行 请求寻路返回", tbParam)
	end)

	
end

return {new = new}