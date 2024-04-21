---@class sims.file_npcs.line
---@field id string 唯一id
---@field nul string 注释说明
---@field model string 模型路径
---@field scale number 模型缩放


---@type ly.common
local common = import_package 'ly.common'

local function new()
	---@class sims.file_npcs
	local api = {}
	local default<const> = "/pkg/sims.res/goap/npcs.txt"
	
	function api.restart()
		api.files = {}
		api.get_file(default)
	end

	function api.get_file(path)
		local file = api.files[path]
		if not file then 
			local lines = common.file.load_csv(path)
			local file = {}
			for i, line in ipairs(lines) do 
				local id = line.id 
				if id and #id > 0 then 
					---@type sims.file_npcs.line
					local tb = {}
					tb.id = id 
					tb.nul = line.nul 
					tb.model = line.model
					tb.scale = tonumber(line.scale) or 1
					file[id] = tb
				end
			end
			api.files[path] = { file = file }
		end
		return file
	end

	---@return sims.file_npcs.line
	function api.get_by_id(id, path)
		local data = api.get_file(path or default)
		return data.file[id]
	end

	return api
end

return {new = new}