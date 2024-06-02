---@type ly.world.main
local sims_world = import_package 'ly.world'
local grid_def = sims_world.get_grid_def()

---@param client sims.client
---@param client_world sims.client.world
local function new(client, client_world)
	---@class sims.client.region
	---@field id number 区域id
	---@field state number 区域状态, 0:正常显示中; 1:请求加载; 2:请求卸载
	---@field distance number 与玩家所在区域的距离
	---@field start vec3 区域起点（世界坐标）
	---@field start_grid vec3 区域起点（客户端格子坐标系）
	---@field grids map<number, entity>
	local api = {}

	--- 销毁区域
	function api.destroy()
		local ecs_world = client.world
		for i, ins in pairs(api.grids) do 
			ecs_world:remove_instance(ins)
		end
		api.grids = {}
		if api.start_grid then 
			client_world.c_world:ClearGridData(api.start_grid.x, api.start_grid.y, api.start_grid.z, 
				client.define.region_size_x, client.define.region_size_y, client.define.region_size_z)
		end
	end

	function api.init(id)
		api.id = id
		api.grids = {}
	end

	--- 设置数据
	---@param data sims.server.region.sync
	function api.set_data(data)
		api.destroy()
		
		api.state = 0
		if not data then return end
		
		api.start = data.start
		local x, y, z = client.define.world_pos_to_grid_pos(api.start.x, api.start.y, api.start.z)
		api.start_grid = {x = x, y = y, z = z}
		local ecs = client.ecs
		local ecs_world = ecs.world
		local iom = ecs.require "ant.objcontroller|obj_motion"
		local math3d = require "math3d"
		local path_grid_def = "/pkg/mod.main/scenes/grid_def.txt"
		for i, grid in ipairs(data.grids) do 
			local index = grid[1]
			local tpl_id = grid[2]
			local x, y, z = client.define.index_to_region_offset(index)
			local def = client.loader.map_grid_def.get_grid_def(path_grid_def, tpl_id)
			if def.model then
				local instance = ecs_world:create_instance {
					prefab = def.model .. "/mesh.prefab",
					on_ready = function(e)
						local tags = e.tag['*']
						local eid = tags[1]
						assert(eid, string.format("failed to create create_instance, model = %s", def.model))
						local ee<close> = ecs_world:entity(eid)
						local pos_x, pos_y, pos_z = x + api.start.x + 0.5, y * 0.5 + api.start.y, z + api.start.z + 0.5
						iom.set_position(ee, math3d.vector(pos_x, pos_y, pos_z))
						iom.set_scale(ee, def.scale)

						local viewId = tags[2]
						local grid_x, grid_y, grid_z = client.define.world_pos_to_grid_pos(pos_x, pos_y, pos_z)
						client_world.ground_cache[viewId] = {grid_x, grid_y, grid_z}
					end
				}
				api.grids[index] = instance

				client_world.c_world:SetGridData(x + api.start_grid.x, y + api.start_grid.y, z + api.start_grid.z, 
					def.size[1] or 1, def.size[2] or 1, def.size[3] or 1, grid_def.Under_Ground)
			end
		end
		for _, npc in ipairs(data.npcs) do 
			client.npc_mgr.create_npc(npc)
		end

		if #data.grids > 0 then 
			client_world.c_world:Update()
		end
	end

	return api
end

return {new = new}