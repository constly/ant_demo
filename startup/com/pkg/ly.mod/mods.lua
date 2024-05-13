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

	---@param tbParams ly.mods.param
	function api.init(tbParams)
		local fs = require "filesystem"
		local bfs = require 'bee.filesystem'
		-- fs遍历vfs目录
		-- bfs遍历本地目录

		for item in bfs.pairs(tbParams.root) do
			print("init", tostring(item))
		end

		--memfs.update("/pkg/testmem/test.txt", "testmem.txt")

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
		for name, item in package(data) do 
			table.insert(rets, name)
		end
		return rets
	end

	-- 刷新指定目录

	-- 得到指定目录下有哪些文件

	-- 删除文件（既要删除vfs，也要删除本地文件）
	
	return api
end

return {new = new}