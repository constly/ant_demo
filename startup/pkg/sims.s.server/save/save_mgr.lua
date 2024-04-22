--------------------------------------------------------------
--- 服务器存档管理
--------------------------------------------------------------

local bfs 			= require "bee.filesystem"

---@param server sims.server 
local function new(server)
	---@class sims.server.save_mgr
	---@field saved_root string 存档根目录
	---@field save_handler sims.server.save_handler 存档数据
	local api = {}
	api.save_handler = require 'save.save_handler'.new(server)

	--- 新建存档
	function api.new_save()
	end

	--- 存档
	function api.save()
		bfs.create_directories(api.saved_root)
		print("存档")
		local data = api.save_handler.get_saved()
		-- 写文件
	end

	--- 读档
	---@param save_id string 存档id
	function api.load_save(save_id)
		print("存档 id")
		-- 加载文件
		api.save_handler.set_saved("");
	end

	--- 读取最近一次存档
	function api.load_save_last()
	end

	--- 存档后马上读档（不写入文件）
	function api.save_and_load()
		local data = api.save_handler.get_saved()
		api.save_handler.set_saved(data)
	end

	return api
end

return {new = new}