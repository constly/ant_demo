---@param mgr sims.s.server.npc_mgr
---@param server sims.s.server
local function new(mgr, server)
	---@class sims.s.server.npc
	---@field id number 唯一id
	---@field tplId number 模板id
	---@field player_id number 所属玩家id
	---@field pos_x number 位置x
	---@field pos_y number 位置y
	---@field pos_z number 位置z
	---@field world sims.s.world.world 所属world
	local api = {move_dir = {}, inner_move_dir = {}}

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
				local region = api.world.get_or_create_region(region_id)
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
		for i, player_id in ipairs(region.notify_players) do 
			server.send_to_player(player_id, cmd, tbParam)
		end
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

	return api
end

return {new = new}