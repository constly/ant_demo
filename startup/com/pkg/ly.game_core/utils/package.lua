---@class ly.game_core.package_item
---@field name string
---@field path string 
---@field isMod boolean 是不是mod包

---@class ly.game_core.file_data
---@field full_path string 全路径
---@field r_path string 相对路径
---@field name string 文件名有后缀名
---@field short_name string 文件名没有后缀名
---@field ext string 后缀名


---@class ly.game_core.tree_item
---@field files ly.game_core.file_data[]
---@field dirs ly.game_core.tree


---@class ly.game_core.tree
---@field full_path string 文件全路径
---@field r_path string 文件相对路径
---@field name string 文件名
---@field tree ly.game_core.tree_item
---@field parent ly.game_core.tree_item

---@return ly.game_core.utils.package
local function new(project_root)
	---@class ly.game_core.utils.package
	local api = {}
	local datalist	= require 'datalist'
	local fastio  	= require "fastio"
	local lfs       = require "bee.filesystem"

	---@type ly.game_core
	local game_core = require 'main'

	---@type ly.common.lib
	local lib 		= import_package 'ly.common'.lib

	---@return ly.game_core.tree_item
	function api.construct_resource_tree(fspath, root)
		local tree = {files = {}, dirs = {}}
		if fspath and lfs.is_directory(fspath) then
			local sorted_path = {}
			for item in lfs.pairs(fspath) do
				sorted_path[#sorted_path+1] = item
			end
			table.sort(sorted_path, function(a, b) return string.lower(tostring(a)) < string.lower(tostring(b)) end)
			for _, item in ipairs(sorted_path) do
				local p = tostring(item)
				local r_path = string.gsub(p, root, "");
				if lfs.is_directory(item) then
					table.insert(tree.dirs, {
						full_path = p, 
						r_path = r_path,
						name = lib.get_file_name(r_path),
						tree = api.construct_resource_tree(item, root), 
						parent = tree
					})
				else
					--local ext = item:extension():string()
					table.insert(tree.files, {
						full_path = p, 
						r_path = r_path, 
						ext = lib.get_file_ext(r_path), 
						name = lib.get_file_name(r_path),
						short_name = lib.get_filename_without_ext(r_path),
					})
				end
			end
		end
		return tree
	end

	---@return ly.game_core.package_item[] 包列表
	function api.get_packages()
		local packages = {}
		if not __ANT_RUNTIME__ then
			local function loadmount(rootpath)
				local path = rootpath .. "/.mount"
				return datalist.parse(fastio.readall_f(path))
			end
			local _mountlpath = {}
			local function addmount(vpath, lpath)
				if not lfs.exists(lpath) then
					return
				end
				assert(vpath:sub(1,1) == "/")
				for _, one in ipairs(_mountlpath) do
					if one.path:string() == lpath then
						return
					end
				end
				_mountlpath[#_mountlpath+1] = {path = lfs.absolute(lpath):lexically_normal(), vpath = vpath}
			end

			local cfg = loadmount(project_root)
			for i = 1, #cfg.mount, 2 do
				local vpath, lpath = cfg.mount[i], cfg.mount[i+1]
				addmount(vpath, lpath:gsub("%%([^%%]*)%%", {
					engine = lfs.current_path():string(),
					project = project_root:gsub("(.-)[/\\]?$", "%1"),
				}))
			end
			for _, one in ipairs(_mountlpath) do
				local value = one.path
				local strvalue = value:string()
				if strvalue:sub(-7) == '/engine' then
					goto continue
				end
				if one.vpath == "/" and strvalue:sub(-4) ~= '/pkg' then
					value = value / 'pkg'
				end
				for item in lfs.pairs(value) do
					local _, pkgname = item:string():match'(.*/)(.*)'
					local skip = false
					if pkgname:sub(1, 4) == "ant." or pkgname:sub(1, 1) == "." then
						skip = true
					end
					if not skip then
						packages[#packages + 1] = {name = pkgname, path = item}
					end
				end
				::continue::
			end
		end

		if game_core.mods then 
			local list = game_core.mods.get_pkgs()
			for i, item in ipairs(list) do 
				packages[#packages + 1] = {name = item.name, path = item.path, isMod = true}
			end
		end

		return packages
	end

	function api.get_pkg_path(pkg_name)
		local packages = api.get_packages()
		for i, item in ipairs(packages) do 
			if item.name == pkg_name then 
				return item.path
			end
		end
	end

	---@param pkg_name string 包名
	---@param relative_path string 相对路径
	---@return string[] 路径列表
	function api.get_all_files(pkg_name, relative_path)
		local fs = require "filesystem"
		local vfs = require "vfs"
		local ret = {}
		local function traverse(root)
			for file in fs.pairs(fs.path(root)) do
				local status = vfs.type(file:string())
				if status == "dir" or status == 'd'  then 
					traverse(file)
				else 
					table.insert(ret, file:string())
				end
			end	
		end

		for d in fs.pairs("/pkg") do
			if d:filename():string() == pkg_name then
				traverse(string.format("%s/%s", d:string(), relative_path))
				break
			end
		end

		return ret
	end
	
	return api
end

return {new = new}