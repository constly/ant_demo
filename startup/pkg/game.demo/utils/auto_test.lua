local ecs = ...
local system = ecs.system "auto_test"
local world = ecs.world
local data_mgr = require 'data_mgr'
local system_name = "game.demo|auto_test"

local all_systems 
local index = 0
local time = 0;
local data_system

function system.init_world()
	index = 0
	system.goto_next()
end

function system.data_changed()
	local cur = os.clock()
	if cur - time >= 0.35 then 
		system.goto_next()
	end
end

function system.goto_next()
	index = index + 1
	if not all_systems or index > #all_systems then 
		all_systems = nil;
		world:disable_system(system_name)
		return
	end

	time = os.clock()
	local data = all_systems[index]
	if data.ok then 
		data_system.set_current_item(data.category, data.item_id)
	else
		system.goto_next() 
	end
end



local api = {}
function api.begin(_data_system)
	local all = {}
	for _, data in ipairs(data_mgr.get_data()) do 
		for _, item in ipairs(data.items) do 
			table.insert(all, {category = data.category, item_id = item.id, ok = item.ok})
		end
	end
	
	data_system = _data_system
	all_systems = all
	world:disable_system(system_name)
	world:enable_system(system_name)
end
return api