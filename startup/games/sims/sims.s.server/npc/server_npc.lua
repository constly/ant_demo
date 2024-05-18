---@class sims.server.npc.sync
---@field id number 唯一id
---@field tplId number npc模板id
---@field world_id number 
---@field pos_x number 位置x
---@field pos_y number 位置y
---@field pos_z number 位置z
---@field dir_x number 朝向x
---@field dir_z number 朝向


---@param server sims.server
local function new(server)
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

	function api.tick(delta_time)
		local speed = 4
		local delta_move = delta_time * speed
		local _x, _z = api.move_dir.x, api.move_dir.z
		local is_move = false
		if _x and _z and (_x ~= 0 or _z ~= 0) then 
			api.pos_x = api.pos_x + _x * delta_move
			api.pos_z = api.pos_z + _z * delta_move

			-- 更新面朝方向
			api.dir_x = _x	
			api.dir_z = _z
			is_move = true
		end

		local cur_region = api.region
		if is_move then
			local region_id = server.define.world_pos_to_region_id(api.pos_x, api.pos_y, api.pos_z)
			if not cur_region or region_id ~= cur_region.id then 
				if cur_region then 
					cur_region.remove_npc(api)
				end
				local region = server.main_world.get_or_create_region(region_id)
				region.add_npc(api)
				cur_region = region
			end
		end

		local x, z = api.inner_move_dir.x, api.inner_move_dir.z
		if _x ~= x or _z ~= z or (_x ~= 0 or _z ~= 0) then 
			api.inner_move_dir.x = _x
			api.inner_move_dir.z = _z

			---@type sims.msg.s2c_npc_move
			local param = {}
			param.id = api.id
			param.dir = {_x or 0, _z or 0}
			param.pos = {api.pos_x, api.pos_y, api.pos_z}
			param.speed = speed
			api.notify_region_players(cur_region, server.msg.s2c_npc_move, param)
		end
	end

	---@param region sims.server.region
	function api.notify_region_players(region, cmd, tbParam)
		if not region then return end 
		for i, player in ipairs(region.notify_players) do 
			server.room.send_to_client(player.fd, cmd, tbParam)
		end
	end

	return api
end	

return {new = new}