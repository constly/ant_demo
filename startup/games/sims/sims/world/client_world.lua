---@type sims.world.main
local sims_world = import_package 'sims.world'

local region_alloc = require 'world.client_region'.new

---@param client sims.client
local function new(client)
	---@class sims.client.world
	---@field regionId number
	---@field regions map<number, sims.client.region> 客户端加载的区域列表
	---@field c_world sims.world.c_world
	local api = {regions = {}}
	api.c_world = sims_world.create_world()
	
	local last_check_pos = {}

	function api.reset()
		last_check_pos = {}
		api.regionId = nil
		for i, v in pairs(api.regions) do 
			v.destroy()
		end
		api.regions = {}
		api.c_world:Reset()
	end

	function api.restart()
		api.reset()
		api.update_current_region()
	end

	function api.tick(delta)
		api.update_current_region()
	end

	--- 设置当前所在的区域id
	---@param regionId number
	function api.set_current_region_id(regionId)
		api.regionId = regionId
		api.update_visible_regions()
	end

	function api.get_region(regionId)
		return api.regions[regionId]
	end

	--- 更新当前所在区域
	function api.update_current_region()
		local pos = client.player_ctrl.position
		if not pos or not pos.x then return end 

		if last_check_pos.x then 
			local delta_x = last_check_pos.x - pos.x
			local delta_y = last_check_pos.y - pos.y
			local delta_z = last_check_pos.z - pos.z
			local dis = math.sqrt(delta_x * delta_x + delta_y * delta_y + delta_z * delta_z)
			if dis < 5 then 
				return;
			end
		end
		last_check_pos.x = pos.x
		last_check_pos.y = pos.y
		last_check_pos.z = pos.z
		local regionId = client.define.world_pos_to_region_id(pos.x, pos.y, pos.z)
		if regionId ~= api.regionId then 
			api.set_current_region_id(regionId)
		end
	end

	--- 更新客户端可见的区域列表
	function api.update_visible_regions()
		local define = client.define
		local pos_x, pos_y, pos_z = define.region_id_to_world_pos(api.regionId)
		local view_x = client.define.player_view_distance_x
		local view_y = client.define.player_view_distance_y
		local view_z = client.define.player_view_distance_z
		local validRegions = {}
		for x = -view_x, view_x, define.region_size_x do 
			for y = -view_y, view_y, define.region_size_y do 
				for z = -view_z, view_z, define.region_size_z do 
					local regionId = define.world_pos_to_region_id(x + pos_x, y + pos_y, z + pos_z)
					local region = api.regions[regionId]
					if not region then 
						region = region_alloc(client, api)
						region.init(regionId)
						region.state = 1
						api.regions[regionId] = region
					end
					region.distance = math.sqrt(x * x + y * y + z * z)
					validRegions[regionId] = true
				end
			end
		end
		local deleteList = {}
		local applyList = {}  ---@type sims.client.region[]
		for regionId, region in pairs(api.regions) do 
			if not validRegions[regionId] then 
				region.state = 2
				region.destroy()
				api.regions[regionId] = nil
				table.insert(deleteList, regionId)
			else 
				if region.state == 1 then 
					table.insert(applyList, region)
				end
			end
		end
		print("applyList count", api.regionId, #applyList)
		table.sort(applyList, function(a, b) return a.distance < b.distance end)
		client.call_server(client.msg.rpc_exit_region, {list = deleteList})
		
		local step = 3
		local len = math.ceil(#applyList / step)
		for i = 1, len do 
			for x = 1, step do 
				local idx = ((i - 1) * step) + x
				if applyList[idx] then
					client.tick_timer.add(i, function()
						client.call_server(client.msg.rpc_apply_region, {region_id = applyList[idx].id})
					end)
				end
			end
		end
	end
	
	return api
end

return {new = new}