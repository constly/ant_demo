--------------------------------------------------------------
--- 服务器存档管理
--------------------------------------------------------------

---@param server sims.server 
local function new(server)
	---@class sims.server.save_mgr
	---@field save_handler sims.server.save_handler 存档数据
	local api = {}
	api.save_handler = require 'save.save_handler'.new(server)

	--- 新建存档
	function api.new_save()
	end

	--- 存档
	function api.save()
		print("存档")
	end

	--- 读档
	---@param save_id string 存档id
	function api.load_save(save_id)
		print("存档 id")
	end

	--- 读取最近一次存档
	function api.load_save_last()
	end

	--- 存档后马上读档
	function api.save_and_load()
		local save_id = api.save()
		api.load_save(save_id)
	end

	return api
end

return {new = new}