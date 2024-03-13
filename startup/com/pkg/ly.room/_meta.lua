
---@class ly.room.param 		匹配模块开启参数
---@field name string 				房间名字
---@field entryCB function	    	进入房间回调
---@field leaveCB function 			退出回调
local tbParam = {}

---@class ly.room.member 		房间成员
---@field id number					成员id
---@field name string 				成员名字
---@field fd number					socket id
---@field is_self boolean			是不是自己
---@field is_leader boolean			是不是房主
---@field code number				通信验证码
local tb_match_member = {}


---@class ly.room.room_list_one 局域网内广播的房间简略数据
---@field ip string 房间id 
---@field type string ip类型: IPv4 or IPv6
---@field port number 房间端口号
---@field name string 房间名 
---@field update_time number 最近更新时间
local tb_room_list_one = {}