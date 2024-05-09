
---@class ly.common.net
local api = {}

---@return string 得到局域网内的ip地址
function api.get_lan_ipv4()
	local ly_net = require 'ly.net'
	local ip = "127.0.0.1"
	local list = ly_net.get_lan_ip_list() or {}
	for i, v in ipairs(list) do 
		if v.type == "IPv4" then 	
			ip = v.ip
			break
		end
	end
	return ip
end

return api