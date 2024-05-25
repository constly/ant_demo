local ltask = require "ltask"

---@param center sims.s.center
local function new(center)
	---@class sims.s.service_mgr
	local api = {}
	api.addrServers = {} 	---@type number[]   所有的server
	api.poolServers = {}	---@type number[]	server缓存池

	---@param totalTime number 服务器运行总时间
	---@param deltaSecond number 本帧间隔，单位秒
	function api.update(totalTime, deltaSecond)
		for _, addr in ipairs(api.addrServers) do 
			ltask.send(addr, "update", totalTime, deltaSecond)
		end
	end	

	function api.shutdown()
		for _, addr in ipairs(api.addrServers) do 
			ltask.send(addr, "shutdown")
		end
		for _, addr in ipairs(api.poolServers) do 
			ltask.send(addr, "shutdown")
		end
		api.addrServers = {}
		api.poolServers = {}
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
		local addr
		if #api.poolServers > 0 then 
			addr = table.remove(api.poolServers, #api.poolServers)
		else 
			addr = ltask.spawn("sims.s.03.server|entry", ltask.self())
		end
		table.insert(api.addrServers, addr)
		return addr
	end

	function api.free_server(addr)
		if not addr then return end 

		for i, v in ipairs(api.addrServers) do 
			if v == addr then 
				table.remove(api.addrServers, i)
				break
			end
		end

		table.insert(api.poolServers, addr)
		ltask.call(addr, "clear")
	end

	return api
end

return {new = new}