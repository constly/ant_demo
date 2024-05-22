--- 服务器启动参数
---@class sims.server.start.params
---@field scene string 启动场景
---@field save_root string 存档根目录
---@field ip string 服务器监听id地址
---@field port number 服务器监听端口号
---@field ip_type string ip类型
---@field room_name string 房间名字
---@field leader_guid string 房主客户端的guid
---@field lan_broadcast_port number 广播端口
---@field addrClient number 客户端主服务地址
---@field addrGate number gate服务地址
---@field addrCenter number 数据中心地址


--- npc登录到world时的参数
---@class sims.server.login.param
---@field world_id number
---@field npc_id number
---@field pos_x number
---@field pos_y number
---@field pos_z number


---@class sims.server.create_world_params
---@field id number 地图id
---@field tpl_id number 地图模板id


--[[

关键字说明:

npc:
	人物
	人物大多数信息都存储在center中，比如所在world_id，装备信息，人际关系；
	人物位置相关信息存储在world中，只在需要时同步到center

object:
	物件，可以在地图中显示的对象
	比如一个建筑，一颗树，一把锄头
	某些object是world的入口

item: ??
	item 与 object的区别是什么
	item 或者 object 是否也要在center注册，不然goap那边无法访问？
	那item数据变化时，是否要同步到center？

world:
	游戏中有多个world，主场景是一个world，主场景中每户人家也是一个world；
	某些公共区域也是一个world，比如体育场；
	各种秘境，副本也是一个个独立的world；
	在游戏运行过程中，会不断的产生新的world和销毁旧的world；
	world主要用于处理npc的移动，为了便于同步，有区域概念
	world中，有一个c_world，用于实时计算地面位置

goap: 
	用于规划npc行为
	center会启动[1-n]个goap服务

nav:
	导航，A* 寻路
	center会启动[1-n]个nav服务
	多个world对应一个nav服务，当world中地形发生变化时，需要同步到nav服务中

center:
	中心服务器，只有一个，为游戏的大脑；
	管理了所有world的入口，以及对world进行负载均衡；
	所有world的npc，都需要在center中注册；

	管理所有goap服务
	管理所有nav服务


模拟经营 之类的呢 ？
	比如种田，家庭/家族的行为活动 


--]]