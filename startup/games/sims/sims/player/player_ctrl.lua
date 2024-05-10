--------------------------------------------------------------
--- 客户端玩家控制器
--------------------------------------------------------------

---@param client sims.client
local function new(client)
	---@class sims.client.player_ctrl
	---@field e_camera number 摄像机
	---@field local_player sims.client_player 本地玩家对象
	---@field move_dir vec2 最近移动方向
	---@field position vec3 玩家所在位置
	local api = {}
	api.local_player = nil
	api.position = {}

	function api.reset()
		if api.e_camera then 
			client.world:remove_entity(api.e_camera)
			api.e_camera = nil
		end
		api.position = {}	
	end

	---@param pos vec3 角色出生的
	function api.restart(pos)
		api.reset()
		-- 创建摄像机
		api.e_camera = client.world:create_entity {
			policy = { "sims|camera" },
			data = {
				comp_camera = {},
			}
		}
		api.position = pos
	end

	--- 设置操控的npc
	---@param npc sims.client.npc
	function api.set_npc(npc)

	end

	function api.get_npc()
		if api.local_player then
			local npc = client.npc_mgr.get_npc_by_id(api.local_player.npc_id)
			if npc and npc.is_ready then 
				return npc 
			end
		end
	end

	return api
end

return {new = new}