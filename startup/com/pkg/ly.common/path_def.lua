local dep = require 'dep' ---@type ly.common.dep
local fs = dep.fs
local lfs               = require "bee.filesystem"
local vfs               = require "vfs"

---@class ly.common.path_def
local api = {}

if __ANT_RUNTIME__ then 
	-- 是否任意ant项目的 fs.current_path() 都是同一个目录呢？ 
	api.cache_root 	= (fs.current_path() / "ant_demo/"):string()
else
	local vfs = require "vfs"
	api.cache_root 	= (fs.path(vfs.repopath()) / ".app" / "cache/"):string()
end

if __ANT_RUNTIME__ then 
	api.data_root 	= (fs.current_path() / "ant_demo/"):string()
else
	local vfs = require "vfs"
	api.data_root 	= (fs.path(vfs.repopath()) / "pkg/game.res/editor"):string()
end

--- 得到所有package包
function api.get_packages()
	print("api.get_packages", __ANT_EDITOR__)
	if not __ANT_EDITOR__ then return {} end
	local fullpath      = lfs.absolute(__ANT_EDITOR__)
	local repo = {_root = fullpath}
	local mount = dofile "/engine/mount.lua"
	mount.read(repo)
    
    local packages = {}
    for _, value in ipairs(repo._mountlpath) do
        local strvalue = value:string()
        if strvalue:sub(-7) == '/engine' then
            goto continue
        end
        if strvalue:sub(-4) ~= '/pkg' then
            value = value / 'pkg'
        end
        for item in lfs.pairs(value) do
            local _, pkgname = item:string():match'(.*/)(.*)'
            local skip = false
            if pkgname:sub(1, 4) == "ant." then
                skip = true
            end
            if not skip then
                packages[#packages + 1] = {name = pkgname, path = item}
            end
        end
        ::continue::
    end
    return packages
end

return api