--------------------------------------------------------------
--- 各种配置表加载相关
--------------------------------------------------------------
---
local function new()
	---@class sims1.loader 文件加载解析相关
	local api = {}
	api.map_data 		= require 'core.loader.file_map_data'.new()
	api.map_grid_def 	= require 'core.loader.file_map_grid_def'.new()
	api.map_list 		= require 'core.loader.file_map_list'.new()
	
	return api
end

return {new = new}