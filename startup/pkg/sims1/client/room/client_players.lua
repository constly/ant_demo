--------------------------------------------------------------
--- 客户端玩家
--------------------------------------------------------------

local function new()
	---@class sims1.client_players
	local api = {} 			
	local next_id = 0;
	api.tb_members = {} 	---@type sims1.client_player[]

	function api.reset()
		next_id = 0
		api.tb_members = {}
	end

	function api.set_members(list)
		api.tb_members = list
	end

	---@return ly.room.member 查找房间成员
	function api.add_member(fd, is_leader)
		next_id = next_id + 1;
		local tb = {} ---@type sims1.client_player
		tb.id = next_id
		tb.name = "玩家" .. next_id
		tb.fd = fd
		tb.is_leader = is_leader
		table.insert(api.tb_members, tb)
		print("add member", fd, next_id, is_leader)
		return tb;
	end

	function api.find_by_id(id)
		for i, v in ipairs(api.tb_members) do 
			if v.id == id then 
				return v
			end 
		end 
	end 

	function api.remove_member(fd)
		print("remove member", fd)
		for i, v in ipairs(api.tb_members) do 
			if v.fd == fd then 
				return table.remove(api.tb_members, i);
			end 
		end 
	end

	return api
end

return {new = new}
