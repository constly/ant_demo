--------------------------------------------------------------
--- npc 存档数据定义
--------------------------------------------------------------

--- 单个普通npc数据
---@class sims.save.npc  
---@field id number npc数据
---@field tpl_id number npc模板id
---@field map_id number 所在地图id
---@field pos_x number 在地图中的位置x
---@field pos_y number 在地图中的位置y
---@field pos_z number 在地图中的位置z
---@field dir_x number 朝向x
---@field dir_z number 朝向z

--- 单个地图npc数据
---@class sims.save.map_npc
---@field npc sims.save.npc npc基础数据
---@field grid_id string 所在格子id

--- 所有npc数据
---@class sims.save.npc_data
---@field next_id number 下个npcid
---@field npcs sims.save.npc[] npc列表
---@field map_npcs map<string, sims.save.map_npc> 地图npc列表



--------------------------------------------------------------
--- map 存档数据定义
--------------------------------------------------------------
--- 地图格子数据
---@class sims.save.grid_data
---@field id number 格子id
---@field tpl_id number 格子模板id

--- 单个地图数据
---@class sims.save.map
---@field id number 地图id
---@field tpl_id string 地图模板id
---@field grid_deleted number[] 删除的格子列表
---@field grids sims.save.grid_data[] 地图上所有发生变化的格子（包括新增的）

--- 所有地图数据
---@class sims.save.map_data
---@field next_id number 下个地图id
---@field maps sims.save.map[] 地图列明


--------------------------------------------------------------
--- 玩家 存档数据定义
--------------------------------------------------------------
--- 单个玩家数据
---@class sims.save.player
---@field id number 玩家id
---@field guid string 玩家guid
---@field npc_id number 操控的npcid
---@field name string 玩家名字
---@field map_id number 所在地图

--- 所有玩家数据
---@class sims.save.player_data
---@field next_id 下个玩家id
---@field players sims.save.player[]
