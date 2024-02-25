local ecs = ...
local system = ecs.system "auto_test"
local world = ecs.world
local data_mgr = require 'data_mgr'


function system.data_changed()
	

end

local api = {}

function api.begin()
	local all = {}
	for _, data in ipairs(data_mgr.get_data()) do 
		for _, item in ipairs(data.items) do 
			table.insert(all, {category = data.category, item_id = item.id})
		end
	end

	for i, v in ipairs(all) do 
		print(i, v.category, v.item_id)
	end
end

return api