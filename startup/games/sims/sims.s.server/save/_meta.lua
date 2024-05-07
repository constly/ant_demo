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
--- world 存档数据定义
--------------------------------------------------------------
--- 区域数据
---@class sims.save.region
---@field id number 区域id
---@field start vec3 区域起始位置
---@field size vec3 区域范围
---@field grids table[] 格子模板id列表

--- 所有地图数据
---@class sims.save.world
---@field id number 世界id
---@field regions sims.save.region[] 区域列表



--------------------------------------------------------------
--- 玩家 存档数据定义
--------------------------------------------------------------
--- 单个玩家数据
---@class sims.save.player
---@field id number 玩家id
---@field guid string 玩家guid
---@field npc_id number 操控的npcid
---@field name string 玩家名字
---@field world_id number 所在世界id

--- 所有玩家数据
---@class sims.save.player_data
---@field next_id 下个玩家id
---@field players sims.save.player[]
