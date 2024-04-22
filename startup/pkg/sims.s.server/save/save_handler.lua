--------------------------------------------------------------
--- 存档数据操作
--------------------------------------------------------------

--- 全局
---@class sims.save.global
---@field next_npc_id number 下个npcid
---@field next_map_id number 下个mapid

--- npc数据
---@class sims.save.npc_data  
---@field id number npc数据
---@field tpl_id number npc模板id
---@field map_id number 所在地图id
---@field pos_x number 在地图中的位置x
---@field pos_y number 在地图中的位置y
---@field pos_z number 在地图中的位置z

--- 地图格子数据
---@class sims.save.grid_data
---@field id number 格子id
---@field tpl_id number 格子模板id

--- 地图数据
---@class sims.save.map_data
---@field grid_deleted number[] 删除的格子列表
---@field grids sims.save.object_data[] 地图上所有发生变化的格子（包括新增的）

--- 存档数据
---@class sims.save_data
---@field global sims.save.global 全局数据
---@field maps sims.save.map_data[] 地图列表
---@field npcs sims.save.npc_data[] npc列表

---@param server sims.server 
local function new(server)
	---@class sims.server.save_handler
	---@field save_data sims.save_data
	local api = {}
	
	--- 初始化
	function api.init()
		---@type sims.save_data
		local data = {}
		data.maps = {}
		data.npcs = {}
		data.global = {}

		api.save_data = data
	end 

	function api.load(path)
	end

	function api.save(path)
	end

	return api
end

return {new = new}