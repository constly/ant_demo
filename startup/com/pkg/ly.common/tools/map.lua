
local window 		= import_package "ant.window"

---@class ly.common.map.params 
---@field feature table 特性列表 
---@field pre string 前一个场景
---@field any any 其他参数

---@class ly.common.map 地图切换相关
---@field tbParam table 地图传入参数
local api 			= {} 

--- 加载地图
---@param tbParam ly.common.map.params 参数
function api.load(tbParam)
	api.tbParam = tbParam
	print("load map", tbParam.feature[1])
	window.reboot({feature = tbParam.feature})
end

return api