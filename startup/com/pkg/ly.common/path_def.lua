local dep = require 'dep' ---@type ly.common.dep
local fs = dep.fs

---@class ly.common.path_def
local api = {}

---@type 项目根目录
api.project_root = nil

---@type mod根目录
api.mod_root = nil

function api.set_project_root(root)
	api.project_root = root

	local root = api.project_root .. "/../publish/mods" 
	if not fs.is_directory(root) then
		root = fs.current_path() .. "/../mods" 
	end
	api.mod_root = fs.absolute(root):lexically_normal():string()
	if not fs.is_directory(api.mod_root) then 
		error("mod 目录不存在")
	end
end

if __ANT_RUNTIME__ then 
	api.cache_root 	= (fs.current_path() / "/"):string()
else
	local vfs = require "vfs"
	local path = vfs.directory("external")
	api.cache_root 	= (fs.path(path) / ".." / "cache/"):string()
end

return api