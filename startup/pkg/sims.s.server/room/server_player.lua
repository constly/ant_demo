
---@param server sims.server
local function new(server, id)
	---@class sims.server_player
	---@field id number 玩家id
	---@field fd number socket连接
	---@field is_leader number 是不是房主
	---@field is_local boolean 是不是本地玩家
	---@field is_online boolean 是否在线
	---@field code number 验证码
	---@field map_id number 所在地图id
	---@field npc sims.server.npc 玩家控制的npc
	local api = {}
	api.id = id
	api.name = "玩家" .. id
	api.is_leader = false
	api.is_online = true
	api.npc = server.npc_mgr.create_player_npc(api) 

	
	return api
end

return {new = new}