--------------------------------------------------------
-- 文件相关
--------------------------------------------------------
local dep 		= require 'dep'
local fs 		= require "filesystem"
local lfs       = require "bee.filesystem"
local imgui_utils = dep.common.imgui_utils

---@class ly.game_editor.package_item
---@field name string
---@field path string 
local tb_package_item = {}

---@class ly.game_editor.tree_item
---@field files string[]
---@field dirs ly.game_editor.tree_item[]
local tb_tree_item = {}

---@return ly.game_editor.files
---@param editor ly.game_editor.editor
local function create(editor)
	---@class ly.game_editor.files
	local api = {} 	
	api.packages = {}  			---@type ly.game_editor.package_item[]
	api.resource_tree = {}		---@type ly.game_editor.tree_item[]

	local function construct_resource_tree(fspath)
		local tree = {files = {}, dirs = {}}
		if fspath then
			local sorted_path = {}
			for item in lfs.pairs(fspath) do
				sorted_path[#sorted_path+1] = item
			end
			table.sort(sorted_path, function(a, b) return string.lower(tostring(a)) < string.lower(tostring(b)) end)
			for _, item in ipairs(sorted_path) do
				--local ext = item:extension():string()
				if lfs.is_directory(item) then
					table.insert(tree.dirs, {item, construct_resource_tree(item), parent = {tree}})
				else
					table.insert(tree.files, item)
				end
			end
		end
		return tree
	end

	local function init()
		local tb_show = {}
		for i, pkg in ipairs(editor.tbParams.pkgs) do 
			tb_show[pkg] = true
		end

		local packages = dep.common.path_def.get_packages()
		local resource_tree = {}
		for _, item in ipairs(packages) do
			if tb_show[item.name] then
				local vpath = fs.path("/pkg") / fs.path(item.name)
				resource_tree[#resource_tree + 1] = {vpath, construct_resource_tree(item.path)}
			end
		end
		dep.common.lib.dump(resource_tree)
		api.resource_tree = resource_tree
		api.packages = packages
	end

	init()
	return api
end

return {create = create}