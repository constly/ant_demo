--------------------------------------------------------------
--- 地图文件数据 接口封装
--------------------------------------------------------------
---@type ly.common
local common = import_package 'ly.common'

---@type ly.game_core
local game_core = import_package 'ly.game_core'

local function new()
	---@class sims1.file_map_data
	local api = {}

	---@type map<string, chess_data_handler>
	api.handlers = {}

	---@return chess_data_handler
	function api.get_data_handler(path)
		local handler = api.handlers[path]
		if not handler then 
			local datalist = common.file.load_datalist(path)
			handler = game_core.create_map_handler()
			handler.init(datalist)
			api.handlers[path] =  handler
		end
		return handler
	end

	---@return string 得到地图格子定义文件
	function api.get_grid_def(map_path)
		local handle = api.get_data_handler(map_path)
		return handle.data.setting.grid_def
	end

	return api
end

return {new = new}