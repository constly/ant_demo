--------------------------------------------------------
-- 代码分析 数据处理
--------------------------------------------------------
local dep 		= require 'dep'
local lfs       = require "bee.filesystem"
local lib 		= dep.common.lib

---@class ly.game_editor.code.data 
---@field name string
---@field lua number lua代码行数
---@field c number c代码行数

---@param editor ly.game_editor.editor
local function new(editor)
	---@class ly.game_editor.code.handler
	---@field data ly.game_editor.code.data[]
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	function api.reload()
		api.data = {}
		local packages = editor.files.get_package(editor.tbParams.project_root)
		local tb = {}
		local total_lua = 0
		for _, item in ipairs(packages) do
			local res = {tree = editor.files.construct_resource_tree(item.path, tostring(item.path) .. "/")}
			local data = api.get_pkg_lines(item.name, res)
			if data.lua > 0 then
				data.name = item.name
				total_lua = total_lua + data.lua
				table.insert(tb, data)
			end
		end
		table.sort(tb, function(a, b)
			if a.lua == b.lua then 
				return a.name < b.name
			end 
			return a.lua > b.lua 
		end)
		table.insert(tb, {name = "合计", lua = total_lua})
		api.data = tb
	end

	local function get_lines(full_path)
		local f<close> = io.open(full_path, 'r')
		local content = f and f:read "a"
		if not content or content == "" then 
			return 0 
		end 
		local lines = lib.split(content, "\n")
		local count = 0;
		for i, line in ipairs(lines) do 
			line = lib.trim(line)
			if #line > 0 then 
				count = count + 1
			end
		end
		return count
	end

	function api.get_pkg_lines(pkg_name, res)
		local data = {lua = 0, c = 0}

		---@param tree ly.game_editor.tree_item
		local function check (tree)
			for i, v in ipairs(tree.dirs) do 
				check(v.tree)
			end
			for i, v in ipairs(tree.files) do 
				if lib.end_with(v.full_path, ".lua") then 
					data.lua = data.lua + get_lines(v.full_path)
				elseif lib.end_with(v.full_path, ".h") or  lib.end_with(v.full_path, ".c") or  lib.end_with(v.full_path, ".cpp") then
					data.c = data.c + get_lines(v.full_path)
				end
			end
		end
		check(res.tree)

		return data
	end

	return api
end 

return {new = new}