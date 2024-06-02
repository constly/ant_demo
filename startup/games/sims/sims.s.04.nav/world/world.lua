---@type ly.world.main
local sims_world = import_package 'ly.world'

---@type sims.core
local core = import_package 'sims.core'

---@param nav sims.s.nav
local function new(nav)
	---@class sims.s.nav.world
	local api = {}
	api.msg = core.new_msg()
	api.c_world = sims_world.create_world()

	---@param tbParam sims.server.create_world_params
	function api.start(tbParam)
		api.msg.init(api.msg.type_nav, api)
	end

	function api.destroy()
		print("destroy nav world")
		api.c_world:Reset()
	end

	--- 设置格子数据
	function api.set_grid_data(args)
		local grid_x, grid_y, grid_z, size_x, size_y, size_z, value = table.unpack(args)
		api.c_world:SetGridData(grid_x, grid_y, grid_z, size_x, size_y, size_z, value)
	end

	---@param tbParam sims.rpc_find_path.param
	function api.find_path(tbParam)
		local start = tbParam.start
		local dest = tbParam.dest
		local bodySize = tbParam.bodySize
		local walkType = tbParam.walkType
		local tb = api.c_world:FindPath(start[1], start[2], start[3], dest[1], dest[2], dest[3], bodySize, walkType)
		if not tb then  
			print(string.format("failed to find path, start=%s,%s,%s  dest=%s,%s,%s", 
				start[1], start[2], start[3], dest[1], dest[2], dest[3]))
		end
		return tb
	end


	return api
end 

return {new = new}