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

	--------------------------------------------------
	-- 存档 和 读档
	--------------------------------------------------
	function api.to_save_data()
		---@type sims.save.player_data
		local data = {}
		data.next_id = next_id
		data.players = {}
		for i, player in pairs(api.players) do 
			---@type sims.save.player
			local tb = {}
			tb.id = player.id
			tb.guid = player.guid
			tb.npc_id = player.npc.id
			tb.name = player.name
			tb.map_id = player.map_id
			table.insert(data.players, tb)
		end
		return data
	end

	---@param data sims.save.player_data
	function api.load_from_save(data)
		local _players = api.players
		local function get_player(id)
			for i, v in ipairs(_players) do 
				if v.id == id then 
					return v;
				end
			end
		end

		next_id = data.next_id or 0
		api.players = {}
		for i, p in ipairs(data.players or {}) do 
			local pre = get_player(p.id)
			---@type sims.server_player
			local player = new_player_handler.new(server, p.id)
			player.guid = p.guid
			player.name = p.name
			player.map_id = p.map_id
			if pre then
				player.fd = pre.fd
				player.code = pre.code
				player.is_leader = pre.is_leader
				player.is_local = pre.is_local
				player.is_online = pre.is_online
			end
			player.npc = server.npc_mgr.get_npc_by_id(p.npc_id) 
			if not player.npc then 
				player.npc = server.npc_mgr.create_player_npc(player)
			end
			server.map_mgr.on_login(player)
			table.insert(api.players, player)
		end
	end

	--------------------------------------------------
	-- 创建 和 销毁player
	--------------------------------------------------
	---@param fd number
	---@param code number
	---@param guid string
	---@return sims.server_player 添加成员
	function api.add_player(fd, code, guid)
		for i, v in ipairs(api.players) do 
			if v.guid == guid then 
				v.fd = fd
				v.code = code
				return v
			end
		end

		next_id = next_id + 1;
		local player = new_player_handler.new(server, next_id)
		player.fd = fd
		player.code = code
		player.guid = guid
		player.npc = server.npc_mgr.create_player_npc(player) 
		table.insert(api.players, player)
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

	function api.remove_player(fd)
		print("remove player", fd)
		for i, v in ipairs(api.players) do 
			if v.fd == fd then 
				return table.remove(api.players, i);
			end 
		end 
	end

	function api.tick(delta_time)
		for i, v in ipairs(api.players) do 
			if v.move_dir then 
				print("delta time", v.move_dir.x, v.move_dir.z)
			end
		end
	end

	return api
end

return {new = new}