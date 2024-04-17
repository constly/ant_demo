
local function new()
	---@class npc
	---@field id number 唯一id
	---@field map_id number 所在地图id
	---@field region_id number 在地图中的区域id
	local api = {}

	function api.init()

	end

	return api
end	

return {new = new}