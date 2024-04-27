--------------------------------------------------------------
--- 服务器存档管理
--------------------------------------------------------------

local bfs 			= require "bee.filesystem"
---@type ly.common
local common		= import_package 'ly.common'

---@param server sims.server 
local function new(server)
	---@class sims.server.save_mgr
	---@field saved_root string 存档根目录
	---@field save_handler sims.server.save_handler 存档数据
	local api = {}
	api.save_handler = require 'save.save_handler'.new(server)

	--- 新建存档
	function api.new_save()
		api.save_handler.set_saved("");
	end

	--- 存档
	function api.save()
		bfs.create_directories(api.saved_root)
		local data = api.save_handler.get_saved()
		local time = os.date("%Y_%m_%d__%H_%M_%S", os.time())
		local _, tf = math.modf(os.clock())
		local path = string.format("%s%s_%s.save", api.saved_root, time, math.floor(tf*1000))
		print("path is", path)
		common.file.save_file(path, data)
	end

	--- 读档
	---@param save_id string 存档id
	function api.load_save(save_id)
		local data
		if save_id and save_id ~= "" then
			local path = string.format("%s%s.save", api.saved_root, save_id)
			data = common.file.load_file(path)
		end
		api.save_handler.set_saved(data);
	end

	--- 覆盖存档
	function api.cover_save(save_id)
		bfs.create_directories(api.saved_root)
		local data = api.save_handler.get_saved()
		local path = string.format("%s%s.save", api.saved_root, save_id)
		common.file.save_file(path, data)
	end

	--- 读取最近一次存档
	function api.load_save_last()
		local save_id = ""
		api.load_save(save_id)
	end

	--- 存档后马上读档（不写入文件）
	function api.save_and_load()
		local data = api.save_handler.get_saved()
		api.save_handler.set_saved(data)
	end

	return api
end

return {new = new}