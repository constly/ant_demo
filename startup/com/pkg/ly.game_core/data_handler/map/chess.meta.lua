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
---@field tpl number 物件模板id
---@field height number 高度偏移
---@field rotate number 物件旋转
---@field hidden boolean 运行时是否默认隐藏
local chess_grid_tpl = {}


-- 棋盘地图区域层数据 模板
---@class chess_map_region_layer_tpl 
---@field id number 层级id
---@field height number 层级高度
---@field active boolean 是否激活
---@field grids table<string, chess_grid_tpl> 格子列表
local chess_map_region_layer_tpl = {}


-- 棋盘地图区域 模板
---@class chess_map_region_tpl 			
---@field id number 区域id 
---@field min chess_vec2 	区域最小位置 
---@field max chess_vec2	区域最大位置
---@field position chess_vec3 世界坐标
---@field rotate number 世界旋转
---@field params table<string,string> 区域参数
---@field layers table<number, chess_map_region_layer_tpl> 层级列表
local chess_map_region_tpl = {}


---@class chess_map_tpl_cache
---@field selects table<number, chess_selected_grid[]> 		regionId -> 选中的格子列表
---@field invisibles table<number, chess_selected_grid>  	regionId -> 不可见的格子列表
local chess_map_tpl_cache = {}


-- 棋盘地图 模板
---@class chess_map_tpl 		
---@field regions chess_map_region_tpl[] 区域列表
---@field region_index number 当前选中的区域索引
---@field next_id number 下个id
---@field cur_object_id number 当前选中的物件id
---@field cache chess_map_tpl_cache 缓存数据
---@field show_ground boolean 是否显示地形
---@field version number 数据版本号
---@field path_def string 物件配置表路径
local chess_map_tpl = {}



--- 选中的格子/物件数据
---@class chess_selected_grid
---@field type string 类型,ground or object
---@field id number|string 选中的id
---@field layer number 所属层级
local chess_selected_grid = {}


--- 棋盘物件模板
---@class chess_object_tpl
---@field id number 唯一id
---@field name string 名字
---@field size chess_vec2 物件大小
---@field bg_color number[] 物件背景颜色
---@field txt_color number[] 文本颜色
---@field bLogic boolean 是不是逻辑物件
---@field nLayer number 层级（用于显示过滤）
local chess_object_tpl = {}

--- 棋盘编辑器创建参数
---@class chess_editor_create_args
---@field data string 内容
---@field tb_objects chess_object_tpl[]
local chess_editor_create_args = {}