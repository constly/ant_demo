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
	if fs.is_directory(root) then
		api.mod_root = fs.absolute(root):lexically_normal():string()
	else 
		error("mod root is nil")
	end
end

if __ANT_RUNTIME__ then 
	-- 是否任意ant项目的 fs.current_path() 都是同一个目录呢？ 
	api.cache_root 	= (fs.current_path() / "/"):string()
else
	local vfs = require "vfs"
	local path = vfs.directory("external")
	api.cache_root 	= (fs.path(path) / ".." / "cache/"):string()
end

return api