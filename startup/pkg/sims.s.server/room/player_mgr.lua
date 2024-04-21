--------------------------------------------------------------
--- 服务器玩家
--------------------------------------------------------------

---@param server sims.server
local function new_player(server, id)
	---@class sims.server_player
	---@field id number 玩家id
	---@field fd number socket连接
	---@field is_leader number 是不是房主
	---@field is_local boolean 是不是本地玩家
	---@field is_online boolean 是否在线
	---@field code number 验证码
	---@field map_id number 所在地图id
	---@field npc sims.server.npc 玩家控制的npc
	local api = {}
	api.id = id
	api.name = "玩家" .. id
	api.is_leader = false
	api.is_online = true

	---@class sims.server.npc.create_param
	local params = {}
	params.mapId = 1
	params.tplId = 1
	api.npc = server.npc_mgr.create_npc(params)

	return api
end


---@param server sims.server
local function new(server)
	---@class sims.server_player_mgr
	local api = {} 		
	local next_id = 0;
	api.tb_members = {} ---@type sims.server_player[]

	function api.reset()
		next_id = 0
		api.tb_members = {}
	end

	function api.reset_players_npc()
		for i, v in ipairs(api.tb_members) do 
			---@type sims.server.npc.create_param
			local tb = {}
			tb.tplId = 1
			tb.mapId = 1
			v.npc = server.npc_mgr.create_npc(tb)
		end
	end

	---@param fd number
	---@param code number
	---@return sims.server_player 添加成员
	function api.add_member(fd, code)
		next_id = next_id + 1;
		local player = new_player(server, next_id)
		player.fd = fd
		player.code = code

		table.insert(api.tb_members, player)
		print("add member", fd, next_id, code)
		return player;
	end

	---@return sims.server_player 查找房间成员
	function api.find_by_id(id)
		for i, v in ipairs(api.tb_members) do 
			if v.id == id then 
				return v
			end 
		end 
	end 

	---@return sims.server_player 查找房间成员
	function api.find_by_fd(fd)
		for i, v in ipairs(api.tb_members) do 
			if v.fd == fd then 
				return v
			end 
		end 
	end

	---@return sims.server_player 查找房间成员
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