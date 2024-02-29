local fs = require "bee.filesystem"

---@class ly.common.path
local api = {}

if __ANT_RUNTIME__ then 
	api.data_root 	= (fs.current_path() / "ant_demo/"):string()
else
	local vfs = require "vfs"
	api.data_root 	= (fs.path(vfs.repopath()) / ".app" / "cache/"):string()
end

return api