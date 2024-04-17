---@type ly.common.main
local common = import_package 'ly.common'
---@type ly.game_core
local game_core = import_package 'ly.game_core'

---@param map_mgr map_mgr
local function new(map_mgr)
	---@class map 
	---@field id number 地图id
	---@field npcs npc[] 地图上npc列表
	---@field regions map<int, region> 区域列表
	local api = {npcs = {}}

	--- 初始化地图
	function api.init(uid, tpl_id)
		local path = "/pkg/mini.richman.res/goap/main_map.map"
		local datalist = common.file.load_datalist(path)
		local map_handler = game_core.create_map_handler()
		map_handler.init(datalist)
	end

	--- 加入地图
	---@param npc npc 
	function api.join(npc)
		npc.map_id = api.id
	end 

	--- 离开地图
	function api.leave(npc)
		npc.map_id = 0
	end

	--- 世界坐标转换为区域坐标
	function api.world_pos_to_region_id(pos_x, pos_y)
	end

	return api
end

return {new = new}