--------------------------------------------------------------
--- 存档数据操作
--------------------------------------------------------------
---@type ly.common
local common		= import_package 'ly.common'

--- 存档数据
---@class sims.save_data
---@field player_data sims.save.player_data 玩家数据
---@field map_data sims.save.map_data 地图数据
---@field npc_data sims.save.npc_data npc数据


---@param server sims.server 
local function new(server)
	---@class sims.server.save_handler
	---@field save_data sims.save_data
	local api = {}

	--- 初始化
	function api.init()
		---@type sims.save_data
		local data = {}
		data.map_data = {}
		data.npc_data = {}
		data.player_data = {}
		api.save_data = data
	end 

	--- 得到存档内容
	function api.get_saved()
		---@type sims.save_data
		local save_data = {}
		save_data.npc_data = server.npc_mgr.to_save_data()
		save_data.map_data = server.map_mgr.to_save_data()
		save_data.player_data = server.player_mgr.to_save_data()

		api.save_data = save_data
		return common.datalist.serialize(save_data)
	end

	--- 设置存档内容
	function api.set_saved(content)
		local data = content and common.datalist.deserialize(content)
		if not data or not data.npc_data then 
			api.init()
		else 
			api.save_data = data
		end
		server.npc_mgr.load_from_save(api.save_data.npc_data)
		server.map_mgr.load_from_save(api.save_data.map_data)
		server.player_mgr.load_from_save(api.save_data.player_data)
	end

	return api
end

return {new = new}