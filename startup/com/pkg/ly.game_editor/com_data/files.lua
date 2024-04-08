--------------------------------------------------------
-- 文件相关
--------------------------------------------------------
---@type ly.game_editor.dep
local dep 		= require 'dep'
local lfs       = require "bee.filesystem"
local lib 		= dep.common.lib

---@class ly.game_editor.package_item
---@field name string
---@field path string 
local tb_package_item = {}

---@class ly.game_editor.file_data
---@field full_path string 全路径
---@field r_path string 相对路径
---@field name string 文件名有后缀名
---@field short_name string 文件名没有后缀名
---@field ext string 后缀名
local tb_file_data = {}

---@class ly.game_editor.tree_item
---@field files ly.game_editor.file_data[]
---@field dirs ly.game_editor.tree
local tb_tree_item = {}

---@class ly.game_editor.tree
---@field full_path string 文件全路径
---@field r_path string 文件相对路径
---@field name string 文件名
---@field tree ly.game_editor.tree_item
---@field parent ly.game_editor.tree_item
local tb_tree = {}

---@return ly.game_editor.files
---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.files
	local api = {} 	
	api.packages = {}  			---@type ly.game_editor.package_item[]
	api.resource_tree = {}		---@type map<string, ly.game_editor.tree>

	---@return ly.game_editor.tree_item
	function api.construct_resource_tree(fspath, root)
		local tree = {files = {}, dirs = {}}
		if fspath then
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

	function api.get_package(entry_path)
		local function loadmount(rootpath)
			local path = rootpath .. "/.mount"
			return dep.datalist.parse(dep.fastio.readall_f(path))
		end
		local _mountlpath = {}
		local function addmount(vpath, lpath)
			if not lfs.exists(lpath) then
				return
			end
			assert(vpath:sub(1,1) == "/")
			for _, value in ipairs(_mountlpath) do
				if value:string() == lpath then
					return
				end
			end
			_mountlpath[#_mountlpath+1] = lfs.absolute(lpath):lexically_normal()
		end

		local cfg = loadmount(entry_path)
		for i = 1, #cfg.mount, 2 do
			local vpath, lpath = cfg.mount[i], cfg.mount[i+1]
			addmount(vpath, lpath:gsub("%%([^%%]*)%%", {
				engine = lfs.current_path():string(),
				project = entry_path:gsub("(.-)[/\\]?$", "%1"),
			}))
		end
		local packages = {}
		for _, value in ipairs(_mountlpath) do
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

	local function init()
		local tb_show = {}
		for i, pkg in ipairs(editor.tbParams.pkgs) do 
			tb_show[pkg] = true
		end
		local packages = api.get_package(editor.tbParams.project_root)
		dep.common.lib.dump(packages)
		
		local resource_tree = {}
		for _, item in ipairs(packages) do
			if tb_show[item.name] then
				local vpath = lfs.path("/pkg") / lfs.path(item.name)
				resource_tree[item.name] = {
					full_path = tostring(item.path), 
					v_path = tostring(vpath),
					r_path = "", 
					tree = api.construct_resource_tree(item.path, tostring(item.path) .. "/")}
			end
		end
		dep.common.lib.dump(resource_tree)
		api.resource_tree = resource_tree
		api.packages = packages
	end

	---@param pkg_name string 包名
	---@param dir string 刷新目录
	function api.refresh_tree(pkg_name, dir)
		local root = api.resource_tree[pkg_name]
		if not root then return end 
		local tree, dir = api.find_tree_by_path(root, dir)
		if tree then 
			local new_tree = api.construct_resource_tree(dir.full_path, root.full_path .. "/")
			tree.files = new_tree.files  
			tree.dirs = new_tree.dirs
		end
	end

	---@return ly.game_editor.tree_item
	function api.find_tree_by_path(root, path)
		if not path or path == "" then return root.tree, root end 
		---@param tree ly.game_editor.tree_item
		local function find(tree)
			for i, file in ipairs(tree.files) do 
				if file.r_path == path then 
					return file, tree
				end
			end
			for i, dir in ipairs(tree.dirs) do 
				if dir.r_path == path then 
					return dir.tree, dir
				end
				local ret, dir = find(dir.tree)
				if ret then 
					return ret, dir
				end
			end
		end
		local ret1, ret2 = find(root.tree)
		return ret1, ret2
	end

	function api.vfs_path_to_full_path(vfs_path)
		if lib.start_with(vfs_path, "/pkg/") then 
			vfs_path = string.gsub(vfs_path, "/pkg/", "")
		end 
		local arr = lib.split(vfs_path, "/")
		if arr[1] == "" then 
			table.remove(arr, 1)
		end
		local pkg = arr[1]
		local r_path = table.concat(arr, "/", 2)
		local root = api.resource_tree[pkg]
		if root then 
			local tree = api.find_tree_by_path(root, r_path)
			return tree and tree.full_path
		end
	end

	function api.get_all_file_by_ext(ext)
		---@param tree ly.game_editor.tree_item
		local function find(tb, tree)
			for i, v in ipairs(tree.dirs) do 
				find(tb, v.tree)
			end
			for i, v in ipairs(tree.files) do 
				if v.ext == ext then 
					table.insert(tb, v.r_path)
				end
			end
		end
		local rets = {}
		for pkg, v in pairs(api.resource_tree) do 
			local tb = {}
			find(tb, v.tree)
			for i, path in ipairs(tb) do 
				table.insert(rets, string.format("/pkg/%s/%s", pkg, path))
			end
		end
		return rets
	end

	init()
	return api
end

return {new = new}