---@type ly.game_editor.dep
local dep = require 'dep'

---@class ly.game_editor.utils
local api = {}

---@param full_path string 文件磁盘路径
---@return string 文本内容
function api.load_file(full_path)
	local f<close> = io.open(full_path, 'r')
	return f and f:read "a"
end

---@param full_path string 文件磁盘路径
---@return table datalist
function api.load_datalist(full_path)
	local content = api.load_file(full_path)
	return content and dep.datalist.parse(content)
end

---@param full_path string 文件磁盘路径
---@param stack common_data_stack
function api.save_file(full_path, data_hander, stack)
	local f<close> = assert(io.open(full_path, "w"))
	f:write(data_hander.to_string())
	data_hander.isModify = false
	stack.on_save()
end

return api