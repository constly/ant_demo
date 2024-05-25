---@class sims.core
local api = {}

---@type sims.define
api.define = require 'define'

local loader_alloc = require 'loader.loader'
local msg_alloc = require 'msg.msg'

---- 文件加载相关
---@return sims.loader
function api.new_loader()
	return loader_alloc.new()
end

--- 客户端/服务器通信协议注册
---@return sims.msg
function api.new_msg()
	return msg_alloc.new()
end

return api