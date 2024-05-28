local ltask = require "ltask"

---@class sims.s.center.service.item
---@field addr number 服务器地址
---@field worlds number[] 哪些world在使用

---@param center sims.s.center
local function new(center)
	---@class sims.s.service_mgr
	local api = {}
	api.addrServers = {} 	---@type number[]   所有的server
	api.poolServers = {}	---@type number[]	server缓存池

	api.addrNavs = {}		---@type sims.s.center.service.item[] 	导航服务器

	function api.start()
		for i = 1, 1 do 
			---@type sims.s.center.service.item
			local item = {}
			item.addr = ltask.spawn("sims.s.04.nav|entry", ltask.self())
			item.worlds = {}
			table.insert(api.addrNavs, item)

			ltask.call(item.addr, "start", center.tbParam)
		end
	end

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
		for _, item in ipairs(api.addrNavs) do 
			ltask.send(item.addr, "shutdown")
		end
		api.addrServers = {}
		api.poolServers = {}
		api.addrNavs = {}
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

	function api.alloc_nav(world_id, world_tpl_id)
		local first = api.addrNavs[1]
		table.insert(first.worlds, world_id)

		---@type sims.server.create_world_params
		local params = {}
		params.id = world_id
		params.tpl_id = world_tpl_id
		ltask.call(first.addr, "create_world", params)
		return first.addr
	end 

	function api.free_nav(world_id, addr)
		for i, v in ipairs(api.addrNavs) do 
			if v.addr == addr then 
				ltask.send(v.addr, "destroy_world", world_id)
				for j, id in ipairs(v.worlds) do 
					if id == world_id then 
						table.remove(v.worlds, j)
						return
					end
				end
			end
		end
	end

	return api
end

return {new = new}