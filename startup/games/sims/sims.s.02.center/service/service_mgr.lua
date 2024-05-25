local ltask = require "ltask"

---@param center sims.s.center
local function new(center)
	---@class sims.s.service_mgr
	local api = {}
	api.addrServers = {} 	---@type number[]   所有的server

	---@param totalTime number 服务器运行总时间
	---@param deltaSecond number 本帧间隔，单位秒
	function api.update(totalTime, deltaSecond)
		for _, addr in ipairs(api.addrServers) do 
			ltask.send(addr, "update", totalTime, deltaSecond)
		end
	end	

	function api.save()
		for _, addr in ipairs(api.addrServers) do 
			ltask.call(addr, "save")
		end
	end

	function api.clear_all_data()
		for _, addr in ipairs(api.addrServers) do 
			ltask.call(addr, "clear")
		end
	end

	function api.alloc_server()
		local addr = ltask.spawn("sims.s.03.server|entry", ltask.self())
		table.insert(api.addrServers, addr)
		return addr
	end

	function api.free_server(addr)
		if not addr then return end 

		ltask.send(addr, "shutdown")
		for i, v in ipairs(api.addrServers) do 
			if v == addr then 
				table.remove(api.addrServers, i)
				return
			end
		end
	end

	return api
end

return {new = new}