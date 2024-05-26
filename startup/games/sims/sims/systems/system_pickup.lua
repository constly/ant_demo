local ecs = ...
local m = ecs.system "system_pickup"
local world = ecs.world
local iviewport = ecs.require "ant.render|viewport.state"
local ipu = ecs.require "ant.objcontroller|pickup.pickup_system"
local iom = ecs.require "ant.objcontroller|obj_motion"

local topick_mb
local pickup_mb
local last_entity

function m.init()
	topick_mb = world:sub{"mouse", "LEFT"}
	pickup_mb = world:sub{"pickup"}
end 

function m.exit()
	world:unsub(topick_mb)
	world:unsub(pickup_mb)
end

--- 摄像机移动控制
function m.data_changed()
	---@type sims.client
	local client = world.client
	
	for _, _, state, x, y in topick_mb:unpack() do
        if state == "DOWN" then
			m.set_scale(last_entity, 1)
            x, y = iviewport.remap_xy(x, y)
            ipu.pick(x, y)
        end
    end
end

function m.after_pickup()
	for _, eid, x, y in pickup_mb:unpack() do 
		m.set_scale(eid, 1.2)
		last_entity = eid
		break
	end
end

function m.set_scale(eid, scale)
	eid = tonumber(eid)
	if not eid then return end 

	local ee<close> = world:entity(eid)
	if ee then 
		iom.set_scale(ee, scale)
	end
end