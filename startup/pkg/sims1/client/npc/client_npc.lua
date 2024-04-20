-----------------------------------------------------------------------
--- 客户端 npc
-----------------------------------------------------------------------


---@param client sims1.client
local function new(client)
	---@class sims1.client.npc
	---@field root number
	---@field model any
	local api = {}
	local world = client.ecs.world

	function api.init()
		-- npc根节点
		api.root = world:create_entity {
			policy = { "sims1|npc_ctrl" },
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
		local e<close> = world:entity(api.root, "comp_play_anim_flag?update comp_play_anim?update")
		if e then 
			e.comp_play_anim_flag = true
			e.comp_play_anim.anim = name
		end
	end

	return api
end

return {new = new}