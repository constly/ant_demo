--------------------------------------------------------------
--- 客户端玩家数据管理
--------------------------------------------------------------

---@class sims.client_player
---@field id number
---@field name string 
---@field map_id number 所在地图id
---@field is_leader number 是不是房主
---@field is_self boolean 是不是自己
---@field is_online boolean 是否在线
---@field npc_id number 操控的npcid

local function new()
	---@class sims.client_players
	local api = {} 			
	local next_id = 0;
	api.players = {} 	---@type sims.client_player[]

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
