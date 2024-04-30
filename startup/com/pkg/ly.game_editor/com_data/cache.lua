--------------------------------------------------------
-- 编辑器缓存数据
--------------------------------------------------------
---@type ly.game_editor.dep
local dep 		= require 'dep'
local common 	= dep.common

---@return ly.game_editor.cache
---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.cache
	local api = {} 	
	local file_path = string.format("%s/%s_cache.ant", common.path_def.cache_root, editor.tbParams.module_name)
	local data

	local function init()
		data = common.file.load_datalist(file_path)
		if type(data) ~= "table" then 
			data = {}
		end		
	end

	function api.save()
		common.file.save_datalist(file_path, data or {})
	end

	function api.get(key)
		local cache = data[key]
		if not cache then 
			cache = {}
			data[key] = cache
		end
		return cache
	end
	
	init()
	return api
end 

return {new = new}