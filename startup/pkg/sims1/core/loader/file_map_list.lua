--------------------------------------------------------------
--- 地图列表文件 接口封装
--------------------------------------------------------------

---@class sims1.file_map_list.line
---@field string number 地图id
---@field name string 地图名字
---@field path string 地图路径
---@field bgm string 背景音乐

---@type ly.common
local common = import_package 'ly.common'

local function new()
	---@class sims1.file_map_list
	local api = {}
	api.data = {}  ---@type map<string, sims1.file_map_list.line>

	local path<const> = "/pkg/sims1.res/goap/map_list.txt"

	function api.reload()
		local lines = common.file.load_csv(path)
		local data = {}
		for i, line in ipairs(lines) do 
			local id = line.id 
			if id and #id > 0 then 
				data[id] = line
			end
		end
		api.data = data
	end

	---@return sims1.file_map_list.line
	function api.get_by_id(id)
		return api.data[id]
	end

	api.reload()
	return api
end

return {new = new}