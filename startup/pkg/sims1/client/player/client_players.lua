--------------------------------------------------------------
--- 客户端玩家数据管理
--------------------------------------------------------------

local function new()
	---@class sims1.client_players
	local api = {} 			
	local next_id = 0;
	api.players = {} 	---@type sims1.client_player[]

	function api.reset()
		next_id = 0
		api.players = {}
	end

	function api.set_members(list)
		api.players = list
	end

	function api.find_by_id(id)
		for i, v in ipairs(api.players) do 
			if v.id == id then 
				return v
			end 
		end 
	end 

	return api
end

return {new = new}
