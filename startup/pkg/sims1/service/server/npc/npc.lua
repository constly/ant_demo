---@param server sims1.server
local function new(server)
	---@class sims1.server.npc
	---@field id number 唯一id
	---@field map_id number 
	---@field region_id number 在地图中的区域id
	---@field pos_x number 位置x
	---@field pos_y number 位置y
	---@field pos_z number 位置z
	local api = {}

	function api.init()

	end

	return api
end	

return {new = new}