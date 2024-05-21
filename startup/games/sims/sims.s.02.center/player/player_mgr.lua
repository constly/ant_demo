--------------------------------------------------------------
--- 服务器玩家管理
--------------------------------------------------------------
local new_player_handler = require 'player.server_player'

---@param center sims.s.center
local function new(center)
	---@class sims.server.player_mgr
	local api = {} 	
	api.players = {} ---@type sims.s.server_player[]

	--------------------------------------------------
	-- 存档 和 读档
	--------------------------------------------------
	function api.to_save_data()
		---@type sims.save.player_data
		local data = {}
		data.players = {}
		for i, player in pairs(api.players) do 
			---@type sims.save.player
			local tb = {}
			tb.id = player.id
			tb.guid = player.guid
			tb.npc_id = player.npc.id
			tb.name = player.name
			tb.world_id = player.world_id
			table.insert(data.players, tb)
		end
		return data
	end

	--- 根据玩家信息新建存档
	function api.get_new_save_data()
		---@type sims.save.player_data
		local data = {}
		data.players = {}
		for i, player in pairs(api.players) do 
			---@type sims.save.player
			local tb = {}
			tb.id = player.id
			tb.guid = player.guid
			tb.name = player.name
			tb.world_id = 1  -- 默认都在1号地图
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
			---@type sims.s.server_player
			local player = new_player_handler.new(center, p.id)
			player.guid = p.guid
			player.name = p.name
			player.world_id = p.world_id
			if pre then
				player.fd = pre.fd
				player.is_leader = pre.is_leader
				player.is_local = pre.is_local
				player.is_online = pre.is_online
			end
			player.npc = center.npc_mgr.get_npc_by_id(p.npc_id) 
			if not player.npc then 
				player.npc = center.npc_mgr.create_player_npc(player)
			end

			--- 登录参数
			---@type sims.server.login.param
			local login_param = {}
			login_param.pos_x = player.npc.pos_x
			login_param.pos_y = player.npc.pos_y
			login_param.pos_z = player.npc.pos_z
			center.main_world.on_login(player, login_param)
			table.insert(api.players, player)
		end
	end

	--------------------------------------------------
	-- 创建 和 销毁player
	--------------------------------------------------
	---@param id number 运行时唯一id
	---@param guid string 客户端唯一guid
	---@return sims.s.server_player 添加成员
	function api.add_player(id, guid)
		for i, v in ipairs(api.players) do 
			if v.guid == guid then 
				v.id = id
				return v
			end
		end

		local player = new_player_handler.new(center, id)
		player.id = id
		player.guid = guid
		player.npc = center.npc_mgr.create_player_npc(player) 
		player.world_id = 1
		table.insert(api.players, player)
		
		print("add player", id, guid)
		return player;
	end

	---@return sims.s.server_player 查找房间成员
	function api.find_by_id(id)
		for i, v in ipairs(api.players) do 
			if v.id == id then 
				return v
			end 
		end 
	end 

	---@return sims.s.server_player 查找房间成员
	function api.find_by_guid(guid)
		for i, v in ipairs(api.players) do 
			if v.guid == guid then 
				return v
			end 
		end 
	end

	function api.notify_player_offline(id)
		print("notify_fd_close player", fd)
		for i, v in ipairs(api.players) do 
			if v.id == id then 
				v.is_online = false
				return
			end 
		end 
	end

	function api.remove_player(id)
		for i, v in ipairs(api.players) do 
			if v.id == id then 
				return table.remove(api.players, i);
			end 
		end 
	end

	function api.tick(delta_time)
		for i, v in ipairs(api.players) do 
			if v.move_dir then 
				local dir = v.npc.move_dir
				dir.x = v.move_dir.x
				dir.y = v.move_dir.y
				dir.z = v.move_dir.z
			end
		end
	end

	--------------------------------------------------
	-- 同步
	--------------------------------------------------
	function api.notify_restart()
		api.refresh_members()
		for i, v in ipairs(api.players) do 
			api.send_to_client(v.fd, center.msg.s2c_restart, {pos = {x = v.npc.pos_x, y = v.npc.pos_y, z = v.npc.pos_z}})
		end
	end

	function api.refresh_members()
		local players = {}
		for i, v in ipairs(api.players) do 
			---@type sims.client_player
			local p = {}
			p.id = v.id
			p.map_id = v.map_id
			p.name = v.name
			p.is_online = v.is_online
			p.is_local = v.is_local
			p.is_leader = v.is_leader
			p.npc_id = v.npc.id
			table.insert(players, p)
		end

		for i, v in ipairs(api.players) do 
			api.send_to_client(v.fd, center.msg.s2c_room_members, players)
		end
	end

	return api
end

return {new = new}