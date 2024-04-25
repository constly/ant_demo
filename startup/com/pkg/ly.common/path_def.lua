local dep = require 'dep' ---@type ly.common.dep
local fs = dep.fs

---@class ly.common.path_def
local api = {}

if __ANT_RUNTIME__ then 
	-- 是否任意ant项目的 fs.current_path() 都是同一个目录呢？ 
	api.cache_root 	= (fs.current_path() / "ant_demo/"):string()
else
	local vfs = require "vfs"
	local path = vfs.directory("external")
	api.cache_root 	= (fs.path(path) / ".." / "cache/"):string()
end

return api