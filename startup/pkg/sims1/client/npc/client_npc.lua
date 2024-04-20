-----------------------------------------------------------------------
--- 客户端 npc
-----------------------------------------------------------------------
---@param client sims1.client
local function new(client)
	---@class sims1.client.npc
	local api = {}
	local root 
	local model 
	local world = client.ecs.world

	function api.init()
		-- 玩家根节点
		root = world:create_entity {
			policy = { "ant.scene|scene_object" },
			data = {
				scene = { 
					s = {1, 1, 1}, 
					t = {0, 0, 0}, 
					r = {0, 0, 0}
				}
			}
		}

		-- 玩家模型, 挂在player下
		model = world:create_instance {
			prefab = "/pkg/game.res/npc/test_003/scene.gltf/mesh.prefab",
			on_ready = function (e)
				world:instance_set_parent(e, root)
			end,
		}
	
	end

	function api.destroy()
		world:remove_entity(root)
		world:remove_instance(model)
	end

	return api
end

return {new = new}