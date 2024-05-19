local ly_net = require 'ly.net'

local function new()
	---@class sims.s.gate
	---@field tbParam sims.s.gate.start_param
	local api = {}

	---@type sims.s.gate.net_handler
	local net_handler = require 'net_handler'.new(api)

	local broadcast
	local broadcast_msg

	---@param tbParam sims.s.gate.start_param
	function api.start(tbParam)
		api.tbParam = tbParam
		net_handler.start(tbParam.ip, tbParam.port)

		assert(not broadcast)
		broadcast = ly_net.CreateBroadCast()
		if not broadcast:init_server("255.255.255.255", tbParam.lan_broadcast_port) then 
			log.warn("failed to create broadcast server, error = " .. broadcast:last_error())
		end

		broadcast_msg = string.format("port&%s;name&%s;ip&%s;type&%s", 
			api.tbParam.port, 
			api.tbParam.name,
			api.tbParam.ip,
			api.tbParam.ip_type)
	end

	function api.shutdown()
		net_handler.close()
		net_handler = nil
		if broadcast then
			broadcast:send("close");
			broadcast:close()
			broadcast = nil
		end
	end

	function api.update()
		if broadcast then
			broadcast:send(broadcast_msg) 
		end
	end

	return api
end

return {new = new}