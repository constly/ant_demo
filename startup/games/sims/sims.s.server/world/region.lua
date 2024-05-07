---@type ly.common
local common = import_package 'ly.common'
local lib = common.lib


---@param world sims.server.world 所属世界
---@param server sims.server
local function new(world, server)
	---@class sims.server.region
	---@field id number 唯一id
	---@field start vec3 区域起点
	---@field npcs sims.server.npc[] 区域中npc列表
	---@field grids map<number, number> 区域中格子列表:index -> 格子模板id 
	---@field notify_players sims.server_player[] 区域数据变化时，需要通知的玩家列表
	local api = {}
	api.npcs = {}
	api.grids = {}
	api.notify_players = {} 

	function api.get_save_data()
		---@type sims.save.region
		local data = {}
		data.id = api.id
		data.start = lib.copy(api.start)
		local list = {}
		for k, v in pairs(api.grids) do 
			table.insert(list, {k, v})
		end
		data.grids = list
		return data
	end

	---@param save_data sims.save.region
	function api.init_from_save(save_data)
		api.id = save_data.id
		api.start = save_data.start
		for i, v in ipairs(save_data.grids) do 
			local idx = v[1]
			local tplId = v[2]
			api.grids[idx] = tplId	
		end
	end

	function api.init(id, start)
		api.id = id 
		api.start = start
		api.grids = {}
	end

	---@return sims.server.grid
	---@param gridTpl chess_grid_tpl
	function api.add_grid(x, y, z, gridTpl)
		local offset_x = x - api.start.x
		local offset_y = (y - api.start.y) * 2
		local offset_z = z - api.start.z
		local idx = server.define.region_offset_to_index(offset_x, offset_y, offset_z)
		api.grids[idx] = gridTpl.tpl
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

	---@param player sims.server_player 玩家对象
	function api.remove_player(player)
		for i, p in ipairs(api.notify_players) do 
			if p == player then 
				table.remove(api.notify_players, i)
				break
			end
		end
	end

	---@param npc sims.server.npc
	function api.add_npc(npc)
		api.npcs[npc.id] = npc
		npc.region = api
	end 

	---@param npc sims.server.npc
	function api.remove_npc(npc)
		api.npcs[npc.id] = nil
		npc.region = nil
	end

	---@class sims.server.region.sync
	---@field grids table[]
	---@field start vec3 区域起点
	-- 得到同步数据
	---@return sims.server.region.sync
	function api.get_sync_data()
		local grids = {}
		for key, tpl_id in pairs(api.grids) do 
			table.insert(grids, {key, tpl_id})
		end

		local npcs = {}
		for i, v in pairs(api.npcs) do 
			table.insert(npcs, v.get_sync_data())
		end
		return {grids = grids, npcs = npcs, start = api.start}
	end

	return api
end

return {new = new}