--------------------------------------------------------------
--- 服务器玩家
--------------------------------------------------------------

local new_player_handler = require 'room.server_player'

---@param server sims.server
local function new(server)
	---@class sims.server_player_mgr
	local api = {} 		
	local next_id = 0;
	api.players = {} ---@type sims.server_player[]

	function api.reset()
		next_id = 0
		api.players = {}
	end

	--------------------------------------------------
	-- 存档 和 读档
	--------------------------------------------------
	function api.to_save_data()
		---@type sims.save.player_data
		local tb = {}
		tb.next_id = next_id
		tb.npcs = {}
		for i, npc in pairs(api.npcs) do 
			---@type sims.save.player
			local tb = {}
			tb.id = npc.id
			table.insert(tb.npcs, tb)
		end
		return tb
	end

	---@param data sims.save.player_data
	function api.load_from_save(data)
		next_id = data.next_id or 0
		api.npcs = {}
		for i, player in ipairs(data.players or {}) do 
			-- create player
		end

		api.reset_players_npc()
	end

	function api.reset_players_npc()
		for i, v in ipairs(api.players) do 
			v.npc = server.npc_mgr.create_player_npc(v)
			server.map_mgr.on_login(v)
		end
	end

	--------------------------------------------------
	-- 创建 和 销毁player
	--------------------------------------------------
	---@param fd number
	---@param code number
	---@return sims.server_player 添加成员
	function api.add_member(fd, code)
		next_id = next_id + 1;
		local player = new_player_handler.new(server, next_id)
		player.fd = fd
		player.code = code

		table.insert(api.players, player)
		print("add member", fd, next_id, code)
		return player;
	end

	---@return sims.server_player 查找房间成员
	function api.find_by_id(id)
		for i, v in ipairs(api.players) do 
			if v.id == id then 
				return v
			end 
		end 
	end 

	---@return sims.server_player 查找房间成员
	function api.find_by_fd(fd)
		for i, v in ipairs(api.players) do 
			if v.fd == fd then 
				return v
			end 
		end 
	end

	---@return sims.server_player 查找房间成员
	function api.find_by_code(code)
		for i, v in ipairs(api.players) do 
			if v.code == code then 
				return v
			end 
		end 
	end

	function api.remove_member(fd)
		print("remove member", fd)
		for i, v in ipairs(api.players) do 
			if v.fd == fd then 
				return table.remove(api.players, i);
			end 
		end 
	end

	return api
end

return {new = new}