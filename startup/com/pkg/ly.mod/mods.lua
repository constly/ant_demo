---@class ly.mods.param mod创建目录
---@field root string mod根目录
---@field excludes string[] 排除哪些mod
---@field includes string[] 只包含哪些mod

---@class ly.mod.item


local function new()
	---@class ly.mods
	local api = {}

	---@type map<string, ly.mod.item>
	local data = {}
	
	local memfs = import_package "ant.vfs".memory
	memfs.init()

	---@type string 根目录
	local root_path = nil

	---@param tbParams ly.mods.param
	function api.init(tbParams)
		local fs = require "filesystem"
		local bfs = require 'bee.filesystem'
		root_path = tbParams.root
		print("set root path", root_path)

		-- fs遍历vfs目录
		-- bfs遍历本地目录

		for file, file_status in bfs.pairs(root_path) do
			if file_status:is_directory() then
				local pkg_name = file:filename():string()
				data[pkg_name] = true
				api.refresh_pkg(pkg_name)
			end
		end
	end

	--- 判断包是不是mod包
	function api.is_mod(pkg_name)
		return data[pkg_name] ~= nil
	end

	--- 移除内存中所有mod
	function api.remove_all()
		for name, item in pairs(data) do 
			memfs.remove("/pkg/" .. name)
		end
	end

	-- 得到有哪些mod 
	function api.get_pkgs()
		local rets = {}
		for name, item in pairs(data) do 
			table.insert(rets, name)
		end
		return rets
	end

	-- 刷新指定pkg
	function api.refresh_pkg(pkg_name)
		memfs.remove("/pkg/" .. pkg_name)

		local bfs = require 'bee.filesystem'
		local function init_files(path, short_path)
			for file, file_status in bfs.pairs(path) do
				local file_name = file:filename():string()
				if file_status:is_directory() then
					init_files(tostring(file), short_path .. file_name .. "/");
				else
					local vfs_path = short_path .. file_name
					local full_path = file:string()
					print("add file", vfs_path, full_path)
					memfs.update(vfs_path, full_path)
				end	
			end
		end
		init_files(root_path .. "/" .. pkg_name, "/pkg/" .. pkg_name .. "/")
	end

	-- 刷新指定目录

	-- 得到指定目录下有哪些文件

	-- 删除文件（既要删除vfs，也要删除本地文件）
	
	return api
end

return {new = new}