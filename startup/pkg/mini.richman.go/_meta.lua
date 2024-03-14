
---@class mrg.client_player
---@field id number
---@field name string 
---@field is_leader number 是不是房主
---@field is_self boolean 是不是自己
local tb_client_player = {} 

---@class mrg.server_player
---@field id number
---@field fd number socket连接
---@field is_leader number 是不是房主
---@field is_local boolean 是不是本地玩家
---@field is_online boolean 是否在线
---@field code number 验证码
local tb_server_player = {} 