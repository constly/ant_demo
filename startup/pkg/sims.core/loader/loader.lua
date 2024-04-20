--------------------------------------------------------------
--- 各种配置表加载相关
--------------------------------------------------------------
---
local function new()
	---@class sims.loader 文件加载解析相关
	local api = {}
	api.map_data 		= require 'loader.file_map_data'.new()
	api.map_grid_def 	= require 'loader.file_map_grid_def'.new()
	api.map_list 		= require 'loader.file_map_list'.new()

	function api.restart()
		api.map_data.restart()
		api.map_grid_def.restart()
		api.map_list.restart()
	end
	
	return api
end

return {new = new}