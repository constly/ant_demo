local grid_handler = require 'map.grid'

---@param map sims.server.map 所属地图
---@param server sims.server
local function new(map, server)
	---@class sims.server.region
	---@field id number 唯一id
	---@field npcs sims.server.npc[] 区域中npc列表
	---@field grids sims.server.grid[] 区域中格子列表
	---@field notify_players sims.server_player[] 区域数据变化时，需要通知的玩家列表
	local api = {}
	api.npcs = {}
	api.grids = {}
	api.notify_players = {} 

	function api.init()

	end

	---@return sims.server.grid
	---@param gridTpl chess_grid_tpl
	function api.add_grid(x, y, z, gridTpl)
		local grid = grid_handler.new()
		grid.init(x, y, z, gridTpl)
		table.insert(api.grids, grid)
		return grid
	end

	---@param player sims.server_player 玩家对象
	function api.add_player(player)
		for i, p in ipairs(api.notify_players) do 
			if p == player then 
				return
			end
		end
		table.insert(api.notify_players, player)
	end

	---@param npc sims.server.npc
	function api.add_npc(npc)
		api.npcs[npc.id] = npc
	end 

	---@param npc sims.server.npc
	function api.remove_npc(npc)
		api.npcs[npc.id] = nil
	end

	---@class sims.server.region.sync
	---@field grids sims.server.grid.sync[]
	---@field npcs sims.server.npc.sync[]
	-- 得到同步数据
	---@return sims.server.region.sync
	function api.get_sync_data()
		local grids = {}
		for i, v in ipairs(api.grids) do 
			table.insert(grids, v.get_sync_data())
		end

		local npcs = {}
		for i, v in pairs(api.npcs) do 
			table.insert(npcs, v.get_sync_data())
		end
		return {grids = grids, npcs = npcs}
	end

	--------------------------------------------------
	-- 每帧更新
	--------------------------------------------------
	function api.tick(delta_time)
		local speed = 4
		local delta_move = delta_time * speed
		for id, npc in pairs(api.npcs) do 
			local _x, _z = npc.move_dir.x, npc.move_dir.z
			if _x and _z and (_x ~= 0 or _z ~= 0) then 
				npc.pos_x = npc.pos_x + _x * delta_move
				npc.pos_z = npc.pos_z + _z * delta_move
			end

			local x, z = npc.inner_move_dir.x, npc.inner_move_dir.z
			if _x ~= x or _z ~= z or (_x ~= 0 or _z ~= 0) then 
				npc.inner_move_dir.x = _x
				npc.inner_move_dir.z = _z

				---@type sims.msg.s2c_npc_move
				local param = {}
				param.id = id
				param.dir = {_x or 0, _z or 0}
				param.pos = {npc.pos_x, npc.pos_y, npc.pos_z}
				param.speed = speed
				api.notify_all_players(server.msg.s2c_npc_move, param)
			end
		end
	end

	--- 通知区域内所有玩家
	function api.notify_all_players(cmd, tbParam)
		for i, player in ipairs(api.notify_players) do 
			server.room.send_to_client(player.fd, cmd, tbParam)
		end
	end

	return api
end

return {new = new}