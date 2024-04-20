--------------------------------------------------------------
--- 客户端玩家控制器
--------------------------------------------------------------

---@param client sims.client
local function new(client)
	---@class sims.client.player_ctrl
	---@field e_camera number 摄像机
	local api = {}

	function api.restart()
		if api.e_camera then 
			client.world:remove_entity(api.e_camera)
		end

		-- 创建摄像机
		api.e_camera = client.world:create_entity {
			policy = { "sims|camera" },
			data = {
				comp_camera = {},
			}
		}
	end

	--- 设置操控的npc
	---@param npc sims.client.npc
	function api.set_npc(npc)

	end

	function api.get_npc()
		return client.npc_mgr.get_npc_by_id(1)
	end

	return api
end

return {new = new}