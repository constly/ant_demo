-----------------------------------------------------------------------
--- 工具函数
-----------------------------------------------------------------------

---@class sims.client.utils
local api = {}

function api.play_animation(world, e, name)
	if type(e) == "number" then 
		local e<close> = world:entity(e, "comp_play_anim_flag?update comp_play_anim?update")
		if e then 
			e.comp_play_anim_flag = true
			e.comp_play_anim.anim = name
		end
	else
		local w = world.w
		w:extend(e, "comp_play_anim_flag?update comp_play_anim?update")
		if e.comp_play_anim then
			e.comp_play_anim_flag = true
			e.comp_play_anim.anim = name
		end
	end
end

--- 得到摄像机旋转角度
---@param comp_camera comp_camera
---@param offset number
function api.get_camera_degree(comp_camera, offset)
	return (comp_camera.angle + (offset or 0)) / 180 * math.pi 
end

return api
