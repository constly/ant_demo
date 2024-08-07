local function new_player()
	---@class sims.s.gate.player
	---@field fd number 网络链接地址
	---@field is_online boolean 是否在线
	---@field guid string 客户端唯一编号
	---@field id number 玩家唯一id
	---@field world_id number 所在world_id
	local api = {}

	return api
end

local function new()
	---@class sims.s.gate.player_mgr
	local api = {}
	api.players = {}  ---@type map<number, sims.s.gate.player>	
	api.next_id = 0

	local cache_id_to_player = {}

	function api.create(guid, fd)
		local p = api.find_by_guid(guid)
		if not p then 
			api.next_id = api.next_id + 1
			p = new_player()
			p.guid = guid
			p.is_online = true
			p.fd = fd
			p.id = api.next_id
			api.players[fd] = p
			cache_id_to_player[p.id] = p
		end
		return p
	end

	function api.find_by_fd(fd)
		return api.players[fd]
	end

	function api.find_by_id(id)
		return cache_id_to_player[id]
	end

	function api.find_by_guid(guid)
		for fd, p in pairs(api.players) do 
			if p.guid == guid then 
				return p, fd
			end
		end
	end 

	function api.set_fd(guid, fd)
		local p, old_fd = api.find_by_guid(guid)
		if p then 
			api.players[old_fd] = nil
			p.fd = fd
			api.players[fd] = p
		end
	end

	function api.notify_fd_close(fd)
		local p = api.players[fd]
		if p then 
			p.is_online = false
		end
	end

	return api
end

return {new = new}