------------------------------------------------------
--- 服务器world
--- 一个world由多个region组成
------------------------------------------------------
local ltask = require "ltask"

---@param center sims.s.center
local function new(center)
	---@class sims.center.world
	---@field id number 唯一id
	---@field addrServer number 所在服务器地址
	---@field addrNav number 对应的导航服务器
	---@field tpl_id number 模板id
	---@field regions map<number, sims.server.region> 区域列表
	local api = {}

	function api.destroy()
		center.service_mgr.free_server(api.addrServer)
		center.service_mgr.free_nav(api.id, api.addrNav)
		api.addrServer = nil
		api.addrNav = nil
	end

	function api.init(id, tpl_id)
		api.id = id
		api.tpl_id = id		
		api.addrServer = center.service_mgr.alloc_server()
		api.addrNav = center.service_mgr.alloc_nav(id, tpl_id)
		ltask.call(api.addrServer, "start", center.tbParam)

		---@type sims.server.create_world_params
		local tbParams = {}
		tbParams.id = id 
		tbParams.tpl_id = tpl_id
		tbParams.addrNav = api.addrNav
		ltask.call(api.addrServer, "create_world", tbParams)
		center.send_to_gate("notify_world_server_id", api.id, api.addrServer)
		center.send_to_gate("notify_world_nav_id", api.id, api.addrNav)
	end

	---@param player sims.s.server_player
	function api.on_login(player)
		local npc = player.npc
		
		---@class sims.s.server.npc
		local tbNpc = npc.get_sync_server()
		ltask.send(api.addrServer, "notify_create_npc", api.id, {tbNpc})

		---@type sims.server.login.param
		local tbParam = {}
		tbParam.world_id = api.id
		tbParam.npc_id = npc.id
		tbParam.pos_x = npc.pos_x
		tbParam.pos_y = npc.pos_y
		tbParam.pos_z = npc.pos_z
		return ltask.call(api.addrServer, "login", tbParam)
	end

	return api
end

return {new = new}