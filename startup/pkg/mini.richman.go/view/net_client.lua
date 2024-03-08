local ltask = require "ltask"

local net = {} ---@class mini.richman.go.net_client
local service
local is_local_player = true

--- 设置是不是本地玩家
---@param v boolean 
function net.set_is_local_player(v)
	is_local_player = v
	if v then 
		service = ltask.uniqueservice "mini.richman.go|richman"
	end
end 

--- 调用服务器
---@param cmd mini.richman.go.def.cmd
function net.call_server(cmd, tbParam)
	if is_local_player then 
		ltask.send(service, "message_process", cmd, tbParam)
	else 
		print("通过网络发送")
	end
end

return net