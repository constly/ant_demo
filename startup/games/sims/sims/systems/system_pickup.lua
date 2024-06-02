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

function m.data_changed()
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
		m.set_scale(eid, 0.8)
		last_entity = eid

		---@type sims.client
		local client = world.client
		local v = client.client_world.get_entity_grid_pos(eid)
		local pos = client.player_ctrl.position
		if v then 
			local start_x, start_y, start_z = client.define.world_pos_to_grid_pos(pos.x, pos.y, pos.z)
			local grid_x, grid_y, grid_z = v[1], v[2] + 1, v[3]
			---@class sims.rpc_find_path.param
			local tbSend = {}
			tbSend.start = {start_x, start_y, start_z}; 			-- 起点
			tbSend.dest = {grid_x, grid_y, grid_z};					-- 终点
			tbSend.bodySize = 1;										-- 身体大小
			tbSend.walkType = client.define.walkType.Ground;			-- 寻路类型
			client.call_server(client.msg.rpc_find_path, tbSend)
		end
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