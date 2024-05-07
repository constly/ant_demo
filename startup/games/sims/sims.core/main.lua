---@class sims.core
local api = {}

---@type sims.define
api.define = require 'define'

---- 文件加载相关
---@return sims.loader
function api.new_loader()
	return require 'loader.loader'.new()
end

--- 客户端/服务器通信协议注册
---@return sims.msg
function api.new_msg()
	return require 'msg.msg'.new()
end

return api