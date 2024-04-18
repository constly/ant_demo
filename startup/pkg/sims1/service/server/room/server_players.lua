--------------------------------------------------------------
--- 服务器玩家
--------------------------------------------------------------

local function new()
	---@class sims1.server_players
	local api = {} 		
	local next_id = 0;
	api.tb_members = {} ---@type sims1.server_player[]

	function api.reset()
		next_id = 0
		api.tb_members = {}
	end

	---@param fd number
	---@param code number
	---@return sims1.server_player 添加成员
	function api.add_member(fd, code)
		next_id = next_id + 1;
		local tb = {} ---@type ly.room.member
		tb.id = next_id
		tb.name = "玩家" .. next_id
		tb.fd = fd
		tb.is_leader = false
		tb.is_online = true
		tb.code = code
		table.insert(api.tb_members, tb)
		print("add member", fd, next_id, code)
		return tb;
	end

	---@return sims1.server_player 查找房间成员
	function api.find_by_id(id)
		for i, v in ipairs(api.tb_members) do 
			if v.id == id then 
				return v
			end 
		end 
	end 

	---@return sims1.server_player 查找房间成员
	function api.find_by_fd(fd)
		for i, v in ipairs(api.tb_members) do 
			if v.fd == fd then 
				return v
			end 
		end 
	end

	---@return sims1.server_player 查找房间成员
	function api.find_by_code(code)
		for i, v in ipairs(api.tb_members) do 
			if v.code == code then 
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