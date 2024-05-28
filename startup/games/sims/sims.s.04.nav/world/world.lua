---@type sims.world.main
local sims_world = import_package 'sims.world'

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
		print("destroy sims world")
		api.c_world:Reset()
	end

	return api
end 

return {new = new}