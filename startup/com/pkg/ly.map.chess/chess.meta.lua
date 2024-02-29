-- 棋盘二维向量
---@class chess_vec2
---@field x number
---@field y number
local chess_vec2 = {}


-- 棋盘三维向量
---@class chess_vec3
---@field x number
---@field y number
---@field z number
local chess_vec3 = {}


-- 棋盘格子数据
---@class chess_grid_tpl 
---@field id number 在地图上的唯一id
---@field tpl number 模板id
---@field height number 高度偏移
---@field rotate number 物件旋转
local chess_grid_tpl = {}


-- 棋盘地图区域层数据 模板
---@class chess_map_region_layer_tpl 
---@field height number 层级高度
---@field grids table<number, chess_grid_tpl> 格子列表
local chess_map_region_layer_tpl = {}


-- 棋盘地图区域 模板
---@class chess_map_region_tpl 			
---@field id number 区域id 
---@field min chess_vec2 	区域最小位置 
---@field max chess_vec2	区域最大位置
---@field position chess_vec3 世界坐标
---@field rotate number 世界旋转
---@field params table<string,string> 区域参数
---@field layers chess_map_region_layer_tpl[] 层级列表
local chess_map_region_tpl = {}


-- 棋盘地图 模板
---@class chess_map_tpl 		
---@field regions chess_map_region_tpl[] 区域列表
---@field next_id number 下个id
local chess_map_tpl = {}


--- 棋盘编辑器创建参数
---@class chess_editor_create_args
---@field path string
local chess_editor_create_args = {}