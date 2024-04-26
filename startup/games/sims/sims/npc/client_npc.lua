-----------------------------------------------------------------------
--- 客户端 npc
-----------------------------------------------------------------------

local utils = require 'utils.utils'

---@param client sims.client
local function new(client)
	---@class sims.client.npc
	---@field root number
	---@field model any
	---@field id number 唯一id
	---@field tplId number 模板id
	local api = {}
	local world = client.world

	---@param syncNpc sims.server.npc.sync
	function api.init(syncNpc)
		api.id = syncNpc.id
		api.tplId = syncNpc.tplId

		local cfg = client.loader.npcs.get_by_id(syncNpc.tplId)
		assert(cfg, string.format("npc 模板id 不存在: %s", syncNpc.tplId or "unknown"))
		assert(cfg.model, string.format("npc=%d 未配置模型", syncNpc.tplId))

		-- npc根节点
		api.root = world:create_entity {
			policy = { "sims|npc_ctrl" },
			data = {
				scene = { 
					s = {cfg.scale, cfg.scale, cfg.scale}, 
					t = {syncNpc.pos_x, syncNpc.pos_y, syncNpc.pos_z}, 
					r = {0, 0, 0}
				},
				comp_instance = {},
				comp_play_anim = {},
				comp_move = {},
			}
		}
		
		-- npc模型, 挂在root下
		api.model = world:create_instance {
			prefab = cfg.model .. "/mesh.prefab",
			on_ready = function (e)
				world:instance_set_parent(e, api.root)
				local p<close> = world:entity(api.root, "comp_instance?update")
				if p and p.comp_instance then 
					p.comp_instance.model = api.model
				end
				api.play_anim("idle_loop")
			end,
		}
	end

	function api.destroy()
		world:remove_entity(api.root)
		world:remove_instance(api.model)
	end

	function api.play_anim(name)
		utils.play_animation(world, api.root, name)
	end

	return api
end

return {new = new}