--------------------------------------------------------
-- 文件相关
--------------------------------------------------------
---@type ly.game_editor.dep
local dep 		= require 'dep'
local lfs       = require "bee.filesystem"
local lib 		= dep.common.lib

---@type ly.game_core
local game_core = import_package 'ly.game_core'

---@return ly.game_editor.files
---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.files
	local api = {} 	
	api.packages = {}  			---@type ly.game_core.package_item[]
	api.resource_tree = {}		---@type sims.server.map<string, ly.game_core.tree>

	local filewatch = require "bee.filewatch".create()
	local watch_paths = {}
	local package_handler = game_core.create_package_handler(editor.tbParams.project_root)
	local pkg_mods = {}

	---@return ly.game_core.tree_item
	function api.construct_resource_tree(fspath, root)
		return package_handler.construct_resource_tree(fspath, root)
	end

	local function init()
		local tb_show = {}
		for i, pkg in ipairs(editor.tbParams.pkgs) do 
			tb_show[pkg] = true
		end
		pkg_mods = {}
		api.packages = package_handler.get_packages()
		local resource_tree = {}
		for _, item in ipairs(api.packages) do
			if tb_show[item.name] then
				local vpath = lfs.path("/pkg") / lfs.path(item.name)
				resource_tree[item.name] = {
					full_path = tostring(item.path), 
					v_path = tostring(vpath),
					r_path = "", 
					tree = api.construct_resource_tree(item.path, tostring(item.path) .. "/")
				}
				if item.isMod then
					pkg_mods[item.name] = true
				end
				filewatch:add(tostring(item.path))
				watch_paths[item.name] = tostring(item.path)
			end
		end
		api.resource_tree = resource_tree
	end

	---@param pkg_name string 包名
	---@param dir string 刷新目录
	function api.refresh_tree(pkg_name, dir)
		local root = api.resource_tree[pkg_name]
		if not root then return end 
		if pkg_mods[pkg_name] and game_core.mods then 
			game_core.mods.refresh_pkg(pkg_name)
		end
		local tree, dir = api.find_tree_by_path(root, dir)
		if tree then 
			local new_tree = api.construct_resource_tree(dir.full_path, root.full_path .. "/")
			tree.files = new_tree.files  
			tree.dirs = new_tree.dirs
		end
	end

	---@return ly.game_core.tree_item
	function api.find_tree_by_path(root, path)
		if not path or path == "" then return root.tree, root end 
		---@param tree ly.game_core.tree_item
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

	function api.vfs_path_to_full_path2(vfs_path)
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
			return root.full_path .. "/" .. r_path;
		end
	end

	function api.get_all_file_by_ext(ext)
		---@param tree ly.game_core.tree_item
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

	function api.update_filewatch()
		local lib = dep.common.lib
		local type, path = filewatch:select()
		local tb_dirty = {}
		while type do
			if type == "modify" or type == "rename" then 
				for name, v in pairs(watch_paths) do 
					if lib.start_with(path, v) then 
						table.insert(tb_dirty, name)
						break
					end
				end
			end
			type, path = filewatch:select()
		end
		for _, name in ipairs(tb_dirty) do 
			api.refresh_tree(name)
		end
	end

	init()
	return api
end

return {new = new}