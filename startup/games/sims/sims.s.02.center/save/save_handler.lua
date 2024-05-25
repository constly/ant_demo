--------------------------------------------------------------
--- 存档数据操作
--------------------------------------------------------------
---@type ly.common
local common		= import_package 'ly.common'

--- 存档数据
---@class sims.save_data
---@field player_data sims.save.player_data 玩家数据
---@field npc_data sims.save.npc_data npc数据
---@field worlds sims.save.worlds world列表


---@param center sims.s.center
local function new(center)
	---@class sims.server.save_handler
	---@field save_data sims.save_data
	local api = {}

	--- 初始化
	function api.init()
		---@type sims.save_data
		local data = {}
		data.npc_data = {}
		data.worlds = {}
		data.player_data = center.player_mgr.get_new_save_data()
		api.save_data = data
	end 

	--- 得到存档内容
	function api.get_saved()
		center.service_mgr.save()

		---@type sims.save_data
		local save_data = {}
		save_data.npc_data = center.npc_mgr.to_save_data()
		save_data.player_data = center.player_mgr.to_save_data()
		save_data.worlds = center.world_mgr.to_save_data()

		api.save_data = save_data
		return common.datalist.serialize(save_data)
	end

	--- 设置存档内容
	function api.set_saved(content)
		center.service_mgr.clear_all_data();
		
		---@type sims.save_data
		local data = content and common.datalist.deserialize(content)
		if not data or not data.npc_data then 
			api.init()
		else 
			api.save_data = data
		end
		center.npc_mgr.load_from_save(api.save_data.npc_data)
		center.world_mgr.load_from_save(api.save_data.worlds)
		center.player_mgr.load_from_save(api.save_data.player_data)
	end

	return api
end

return {new = new}