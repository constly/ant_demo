-----------------------------------------------------------------------
--- 客户端 npc
-----------------------------------------------------------------------

local utils = require 'utils.utils'
---@type ly.common
local common = import_package 'ly.common'
local async = common.async

---@param client sims.client
local function new(client)
	---@class sims.client.npc
	---@field root number
	---@field model any
	---@field id number 唯一id
	---@field tplId number 模板id
	---@field is_ready boolean 是否准备就绪
	local api = {}
	local world = client.world
	local aync_instance = async.new(client.world)

	---@param syncNpc sims.server.npc.sync
	function api.init(syncNpc)
		api.id = syncNpc.id
		api.tplId = syncNpc.tplId

		local cfg = client.loader.npcs.get_by_id(syncNpc.tplId)
		assert(cfg, string.format("npc 模板id 不存在: %s", syncNpc.tplId or "unknown"))
		assert(cfg.model, string.format("npc=%d 未配置模型", syncNpc.tplId))
		print(string.format("create npc id:%d pos:%s %s %s dir:%s %s", syncNpc.id, syncNpc.pos_x, syncNpc.pos_y, syncNpc.pos_z, syncNpc.dir_x, syncNpc.dir_z))

		aync_instance(function(async)
			-- npc根节点
			api.root = async:async_entity {
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
			api.model = async:async_instance {
				prefab = cfg.model .. "/mesh.prefab",
			}
			async.wait()
			if not api.model then return end 

			world:instance_set_parent(api.model, api.root)
			local p<close> = world:entity(api.root, "comp_instance?update")
			if p and p.comp_instance then 
				p.comp_instance.model = api.model
			end

			if syncNpc.dir_x then
				local math3d = require "math3d"
				local iom = client.ecs.require "ant.objcontroller|obj_motion"
				iom.set_direction(p, math3d.vector(-syncNpc.dir_x, 0, -syncNpc.dir_z))
			end
			api.play_anim("idle_loop")
			api.is_ready = true
		end)		
		
	end

	function api.destroy()
		api.is_ready = false
		if api.model then
			world:remove_entity(api.root)
			world:remove_instance(api.model)
			api.model = nil
		end
	end

	function api.play_anim(name)
		utils.play_animation(world, api.root, name)
	end

	return api
end

return {new = new}