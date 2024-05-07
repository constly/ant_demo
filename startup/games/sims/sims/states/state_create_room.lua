-----------------------------------------------------------------------
--- 创建房间
-----------------------------------------------------------------------

---@param s sims.client.state_machine
---@param client sims.client
local function new(s, client)
	local api = {} ---@type sims.client.state_machine.state_base 
	function api.on_entry()
		client.call_server(s.msg.rpc_login, {code = 0})
	end

	function api.on_update()
	end

	function api.on_exit()
	end

	return api
end

return {new = new}