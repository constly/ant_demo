-----------------------------------------------------------------------
--- 房间运行中
-----------------------------------------------------------------------

---@param s sims.client.state_machine
---@param client sims.client
local function new(s, client)
	local ly_net = require 'ly.net'
	local api = {} ---@type sims.client.state_machine.state_base 

	local broadcast
	local broadcast_msg

	function api.on_entry()
	end

	function api.on_destroy()
		broadcast = nil
	end

	function api.on_update()
		client.editor.update()
		if client.is_listen_player then 
			api.broadcast_room_addr()
		end
	end

	function api.broadcast_room_addr()
		if not broadcast then
			broadcast = ly_net.CreateBroadCast()
			if not broadcast:init_server("255.255.255.255", client.lan_broadcast_port) then 
				log.warn("failed to create broadcast server, error = " .. broadcast:last_error())
			end
		end
		if not broadcast_msg then
			local param = client.create_room_param
			broadcast_msg = string.format("port&%s;name&%s;ip&%s;type&%s;state&%d", param.port, param.room_name, param.ip, param.ip_type, 2)
		end
		broadcast:send(broadcast_msg) 
	end

	function api.on_exit()
		broadcast_msg = nil
	end

	return api
end

return {new = new}