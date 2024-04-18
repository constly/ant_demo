--------------------------------------------------------------
--- 服务器玩家
--------------------------------------------------------------

---@param server sims1.server
local function new_player(server, id)
	---@class sims1.server_player
	local api = {}
	api.id = id
	api.name = "玩家" .. id
	api.is_leader = false
	api.is_online = true
	api.npc = server.npc_mgr.create_npc()

	return api
end


---@param server sims1.server
local function new(server)
	---@class sims1.server_player_mgr
	local api = {} 		
	local next_id = 0;
	api.tb_members = {} ---@type sims1.server_player[]

	function api.reset()
		next_id = 0
		api.tb_members = {}
	end

	---@param fd number
	---@param code number
	---@return sims1.server_player 添加成员
	function api.add_member(fd, code)
		next_id = next_id + 1;
		local player = new_player(server, next_id)
		player.fd = fd
		player.code = code

		table.insert(api.tb_members, player)
		print("add member", fd, next_id, code)
		return player;
	end

	---@return sims1.server_player 查找房间成员
	function api.find_by_id(id)
		for i, v in ipairs(api.tb_members) do 
			if v.id == id then 
				return v
			end 
		end 
	end 

	---@return sims1.server_player 查找房间成员
	function api.find_by_fd(fd)
		for i, v in ipairs(api.tb_members) do 
			if v.fd == fd then 
				return v
			end 
		end 
	end

	---@return sims1.server_player 查找房间成员
	function api.find_by_code(code)
		for i, v in ipairs(api.tb_members) do 
			if v.code == code then 
				return v
			end 
		end 
	end

	function api.remove_member(fd)
		print("remove member", fd)
		for i, v in ipairs(api.tb_members) do 
			if v.fd == fd then 
				return table.remove(api.tb_members, i);
			end 
		end 
	end

	return api
end

return {new = new}