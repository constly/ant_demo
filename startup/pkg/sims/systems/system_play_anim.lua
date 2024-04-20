local ecs = ...
local m = ecs.system "system_play_anim"
local world = ecs.world
local w = world.w
local iplayback = ecs.require "ant.animation|playback"
local ianimation = ecs.require "ant.animation|animation"

function m.data_changed()
	for e in w:select "comp_play_anim_flag:update comp_instance:in comp_play_anim:update" do
		local instance = e.comp_instance ---@type comp_play_anim
		local play_anim = e.comp_play_anim  ---@type comp_play_anim
		if instance.model and play_anim.anim ~= play_anim.last_anim then 
			local entities = instance.model.tag['*']
			for i = 1, #entities do
				local eid = entities[i]
				local e <close> = world:entity(eid, "animation?in")
				if e and e.animation then
					if play_anim.last_anim then 
						iplayback.set_play(e, play_anim.last_anim, false)
						ianimation.set_weight(e, play_anim.last_anim, 0)
					end
					iplayback.set_play(e, play_anim.anim, true)
					iplayback.completion_loop(e, play_anim.anim)
					ianimation.set_weight(e, play_anim.anim, 1)
				end
			end
			play_anim.last_anim = play_anim.anim
		end
		e.comp_play_anim_flag = false
	end
end