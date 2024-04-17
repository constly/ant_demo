local function new()
	---@class region
	---@field id number 唯一id
	---@field npcs npc[] 区域中npc列表
	---@field grids grid[] 区域中格子列表
	local api = {}

	return api
end

return {new = new}