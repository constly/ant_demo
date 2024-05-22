---@class sims.server.npc.sync
---@field id number 唯一id
---@field tplId number npc模板id
---@field world_id number 
---@field player_id number 所属玩家id
---@field pos_x number 位置x
---@field pos_y number 位置y
---@field pos_z number 位置z
---@field dir_x number 朝向x
---@field dir_z number 朝向


---@param center sims.s.center
local function new(center)
	---@class sims.server.npc
	---public
	---@field id number 唯一id
	---@field tplId number npc模板id
	---@field world_id number 
	---@field region table 在地图中的区域
	---@field pos_x number 位置x
	---@field pos_y number 位置y
	---@field pos_z number 位置z
	---@field dir_x number 面朝方向
	---@field dir_z number 面朝方向
	---@field move_dir vec3 移动方向
	---@field player sims.server_player 所属玩家
	---private
	---@field inner_move_dir vec3 实际移动方向（）
	local api = {}

	---@param params sims.server.npc.create_param
	function api.init(uid, params)
		api.id = uid
		api.tplId = tostring(params.tplId)
		api.world_id = params.world_id
		api.pos_x = params.pos_x
		api.pos_y = params.pos_y
		api.pos_z = params.pos_z
		api.dir_x = params.dir_x
		api.dir_z = params.dir_z
		api.move_dir = {x = 0, z = 0}
		api.inner_move_dir = {x = 0, z = 0}
	end

	--- 得到同步到客户端的数据
	function api.get_sync_data()
		---@type sims.server.npc.sync
		local npc = {}
		npc.id = api.id
		npc.tplId = api.tplId
		npc.world_id = api.world_id
		npc.pos_x = api.pos_x
		npc.pos_y = api.pos_y
		npc.pos_z = api.pos_z
		npc.dir_x = api.dir_x
		npc.dir_z = api.dir_z
		return npc
	end

	--- 得到存档数据
	function api.get_save_data()
		---@type sims.save.npc
		local npc = {}
		npc.id = api.id
		npc.tpl_id = api.tplId
		npc.world_id = api.world_id
		npc.pos_x = api.pos_x
		npc.pos_y = api.pos_y
		npc.pos_z = api.pos_z
		npc.dir_x = api.dir_x
		npc.dir_z = api.dir_z

		if api.gridId then 
			---@type sims.save.map_npc
			local m = {}
			m.npc = npc
			m.grid_id = api.gridId
			return "map_npc", m
		else 
			return "npc", npc
		end
	end

	--- 得到同步到server的数据
	---@return sims.s.server.npc
	function api.get_sync_server()
		---@class sims.s.server.npc
		local tbNpc = {}
		tbNpc.id = api.id
		tbNpc.player_id = api.player and api.player.id or nil
		tbNpc.pos_x = api.pos_x
		tbNpc.pos_y = api.pos_y
		tbNpc.pos_z = api.pos_z
		return tbNpc
	end

	return api
end	

return {new = new}