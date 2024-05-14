---@type ly.common
local common = import_package 'ly.common'

---@param api sims.msg
local function new(api)

	---@class sims.msg.s2c_npc_move
	---@field id number npcId
	---@field speed number 速度
	---@field dir number[] 移动方向
	---@field pos number[] npc位置

	-- 通知npc移动
	api.reg_s2c(api.s2c_npc_move, function(tbParam)
		---@type sims.msg.s2c_npc_move
		local p = tbParam
		local npc = api.client.npc_mgr.get_npc_by_id(p.id)
		if not npc then 
			api.client.call_server(api.rpc_apply_npc_data, {id = p.id})
			return 
		end 

		local world = api.client.world
		local e<close> = world:entity(npc.root, "comp_move:update")
		if e then
			---@type sims.msg.s2c_npc_move
			local s = e.comp_move.server 
			if not s then 
				s = {}
				e.comp_move.server = s
			end
			s.dir = p.dir
			s.pos = p.pos
			s.speed = p.speed
		end
	end)

	api.reg_rpc(api.rpc_apply_npc_data, function(player, tbParam)
		local npcId = tbParam.id
		local npc = api.server.npc_mgr.get_npc_by_id(npcId)
		if npc then 
			return {data = npc.get_sync_data()}
		end
	end, function(tbParam)
		api.client.npc_mgr.create_npc(tbParam.data)
	end)
end



return {new = new}