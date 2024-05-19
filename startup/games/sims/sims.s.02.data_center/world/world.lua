------------------------------------------------------
--- 服务器world
--- 一个world由多个region组成
------------------------------------------------------
---@param data_center sims.s.data_center
local function new(data_center)
	---@class sims.server.world
	local api = {}


	---@param player sims.server_player
	---@param login_param sims.server.login.param
	function api.on_login(player, login_param)
		
	end

	return api
end

return {new = new}