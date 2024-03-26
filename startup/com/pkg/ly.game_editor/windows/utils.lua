---@type ly.game_editor.dep
local dep = require 'dep'

---@class ly.game_editor.utils
local api = {}

---@param full_path string 文件磁盘路径
function api.load_file(full_path)
	local f<close> = io.open(full_path, 'r')
	return f and dep.datalist.parse( f:read "a" )
end

---@param full_path string 文件磁盘路径
---@param stack common_data_stack
function api.save_file(full_path, data_hander, stack)
	local data = data_hander.data
	local cache = data.cache
	data.cache = nil
	local content = dep.serialize.stringify(data)
	local f<close> = assert(io.open(full_path, "w"))
	f:write(content)
	data.cache = cache
	data_hander.isModify = false
	stack.on_save()
end

return api