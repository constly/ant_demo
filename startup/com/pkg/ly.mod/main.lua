---@class ly.mod
---@field mods ly.mods
local api = {}

---@return ly.mods
---@param tbParams ly.mods.param
function api.init(tbParams)
	if not api.mods then 
		local mods_handler = require 'mods'
		api.mods = mods_handler.new()
	end
	api.mods.remove_all()
	api.mods.init(tbParams)
	return api.mods
end


return api