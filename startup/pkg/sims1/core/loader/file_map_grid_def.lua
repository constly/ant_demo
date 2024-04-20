--------------------------------------------------------------
--- 地图格子定义 接口封装
--------------------------------------------------------------
---@type ly.common
local common = import_package 'ly.common'

---@class sims1.grid_def.line
---@field id number 唯一id
---@field name string 格子名字 
---@field size number[] 格子大小
---@field bg_color number[] 格子背景颜色
---@field txt_color number[] 格子文本颜色
---@field model string 格子模型路径
---@field scale number[] 模型缩放

local function new()
	---@class sims1.file_map_grid_def
	---@field data map<string, map<int, sims1.grid_def.line>> 
	local api = {}
	
	function api.restart()
		api.data = {}
	end

	function api.get_file_data(path)
		local data = api.data[path]
		if not data then 
			local lines = common.file.load_csv(path)
			data = {}
			for i, line in ipairs(lines) do 
				local id = tonumber(line.id) or 0
				if id > 0 then 
					local tb = {} ---@type sims1.grid_def.line
					tb.id = id 
					tb.name = line.name
					tb.size = common.lib.eval(line.size)
					tb.model = line.model
					tb.scale = common.lib.eval(line.scale) or {1, 1, 1}
					data[id] = tb
				end
			end
			api.data[path] = data
		end 
		return data
	end

	---@param path string 文件路径
	---@param grid_tpl_id number 格子模板id
	---@return sims1.grid_def.line
	function api.get_grid_def(path, grid_tpl_id)
		local data = api.get_file_data(path)
		return data[grid_tpl_id]
	end

	return api
end

return {new = new}