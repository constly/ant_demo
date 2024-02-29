local dep = require 'dep' ---@type ly.common.dep
local fs = dep.fs

---@class ly.common.path_def
local api = {}

if __ANT_RUNTIME__ then 
	api.data_root 	= (fs.current_path() / "ant_demo/"):string()
else
	local vfs = require "vfs"
	api.data_root 	= (fs.path(vfs.repopath()) / ".app" / "cache/"):string()
end

return api