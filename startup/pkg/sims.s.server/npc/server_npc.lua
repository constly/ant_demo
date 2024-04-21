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
	---@field id number 唯一id
	---@field tplId number npc模板id
	---@field map_id number 
	---@field region_id number 在地图中的区域id
	---@field pos_x number 位置x
	---@field pos_y number 位置y
	---@field pos_z number 位置z
	local api = {}

	---@param params sims.server.npc.create_param
	function api.init(uid, params)
		api.id = uid
		api.tplId = tostring(params.tplId)
		api.map_id = params.mapId
		api.pos_x = params.pos_x
		api.pos_y = params.pos_y
		api.pos_z = params.pos_z
	end

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

	return api
end	

return {new = new}