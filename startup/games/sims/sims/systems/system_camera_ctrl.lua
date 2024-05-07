local ecs = ...
local m = ecs.system "system_camera_ctrl"
local world = ecs.world
local w = world.w
local math3d = require "math3d"
local iom = ecs.require "ant.objcontroller|obj_motion"
local utils = require 'utils.utils'

---@param client sims.client
local function update (client, pe, camera_cfg)
	local mq = w:first("main_queue camera_ref:in render_target:in")
	local ce <close> = world:entity(mq.camera_ref, "scene:update")
	local pos = iom.get_position(pe)
	local tpos = math3d.tovalue(pos)	-- 玩家位置

	local degree = utils.get_camera_degree(camera_cfg, 90)
	local offset_x = camera_cfg.offset_x * math.cos(degree) - camera_cfg.offset_z * math.sin(degree)
	local offset_z = camera_cfg.offset_z * math.cos(degree) + camera_cfg.offset_x * math.sin(degree)
	local view_target = math3d.vector(tpos[1] + offset_x, tpos[2] + camera_cfg.offset_y, tpos[3] + offset_z)
	tpos = math3d.tovalue(view_target)

	local degree = utils.get_camera_degree(camera_cfg) 
	local new_x = tpos[1] + math.cos(degree) * camera_cfg.dis;
	local new_y = tpos[2] + camera_cfg.height
	local new_z = tpos[3] + math.sin(degree) * camera_cfg.dis
	local camera_pos = math3d.vector(new_x, new_y, new_z)

	local viewdir = math3d.sub(view_target, camera_pos) 
	iom.lookto(ce, camera_pos, viewdir)
	local ps = client.player_ctrl.position 
	ps.x = tpos[1]
	ps.y = tpos[2]
	ps.z = tpos[3]
end

--- 摄像机移动控制
function m.data_changed()
	---@type sims.client
	local client = world.client
	local eid = client.player_ctrl.e_camera
	local npc = client.player_ctrl.get_npc()
	if not eid or not npc then return end 

	local e<close> = world:entity(eid, "comp_camera?in")
	if e then 
		local pe<close> = world:entity(npc.root)
		update(client, pe, e.comp_camera)
	end
end


