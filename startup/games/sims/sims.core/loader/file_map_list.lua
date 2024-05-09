--------------------------------------------------------------
--- 地图列表文件 接口封装
--------------------------------------------------------------

---@class sims.file_map_list.line
---@field id string 地图id
---@field name string 地图名字
---@field path string 地图路径
---@field bgm string 背景音乐
---@field position number[] 世界位置
---@field world number 所属world

---@type ly.common
local common = import_package 'ly.common'

local function new()
	---@class sims.file_map_list
	---@field data map<string, sims.file_map_list.line>
	local api = {}
	
	---@param tbParam sims.core.loader.param
	function api.restart(tbParam)
		api.data = {}
		api.reload(tbParam)
	end

	---@param tbParam sims.core.loader.param
	function api.reload(tbParam)
		local path = tbParam.path_map_list
		local lines = common.file.load_csv(path)
		local data = {}
		for i, line in ipairs(lines) do 
			local id = line.id 
			if id and #id > 0 then 
				---@type sims.file_map_list.line
				local tb = {}
				tb.id = line.id
				tb.name = line.name
				tb.path = line.path
				tb.bgm = line.bgm
				tb.world = tonumber(line.world) or 0
				tb.position = common.lib.eval(line.position) or {}
				data[id] = tb
			end
		end
		api.data = data
	end

	---@return sims.file_map_list.line
	function api.get_by_id(id)
		return api.data[id]
	end

	return api
end

return {new = new}