
local function new()
	---@class sims.s.world
	local api = {}

	function api.start()
	end 

	function api.shutdown()
		print("close sims world")
	end

	return api
end

return {new = new}