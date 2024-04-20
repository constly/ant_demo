-----------------------------------------------------------------------
--- 客户端 npc
-----------------------------------------------------------------------

local utils = require 'utils.utils'

---@param client sims.client
local function new(client)
	---@class sims.client.npc
	---@field root number
	---@field model any
	local api = {}
	local world = client.world

	function api.init()
		-- npc根节点
		api.root = world:create_entity {
			policy = { "sims|npc_ctrl" },
			data = {
				scene = { 
					s = {1, 1, 1}, 
					t = {0, 0, 0}, 
					r = {0, 0, 0}
				},
				comp_instance = {},
				comp_play_anim = {},
				comp_move = {},
			}
		}

		-- npc模型, 挂在root下
		api.model = world:create_instance {
			prefab = "/pkg/game.res/npc/test_003/scene.gltf/mesh.prefab",
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