---@class sims.server.npc.sync
---@field id number 唯一id
---@field tplId number npc模板id
---@field map_id number 
---@field region_id number 在地图中的区域id
---@field pos_x number 位置x
---@field pos_y number 位置y
---@field pos_z number 位置z


---@param server sims.server
local function new(server)
	---@class sims.server.npc
	---public
	---@field id number 唯一id
	---@field tplId number npc模板id
	---@field gridId string 所属地图格子id
	---@field map_id number 
	---@field region_id number 在地图中的区域id
	---@field pos_x number 位置x
	---@field pos_y number 位置y
	---@field pos_z number 位置z
	---@field move_dir vec3 移动方向
	---private
	---@field inner_move_dir vec2 实际移动方向（）
	local api = {}

	---@param params sims.server.npc.create_param
	function api.init(uid, params)
		api.id = uid
		api.tplId = tostring(params.tplId)
		api.map_id = params.mapId
		api.pos_x = params.pos_x
		api.pos_y = params.pos_y
		api.pos_z = params.pos_z
		api.move_dir = {x = 0, z = 0}
		api.inner_move_dir = {x = 0, z = 0}
	end

	--- 得到同步到客户端的数据
	function api.get_sync_data()
		---@type sims.server.npc.sync
		local npc = {}
		npc.id = api.id
		npc.tplId = api.tplId
		npc.map_id = api.map_id
		npc.region_id = api.region_id
		npc.pos_x = api.pos_x
		npc.pos_y = api.pos_y
		npc.pos_z = api.pos_z
		return npc
	end

	--- 得到存档数据
	function api.get_save_data()
		---@type sims.save.npc
		local npc = {}
		npc.id = api.id
		npc.tpl_id = api.tplId
		npc.map_id = api.map_id
		npc.pos_x = api.pos_x
		npc.pos_y = api.pos_y
		npc.pos_z = api.pos_z

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

	return api
end	

return {new = new}