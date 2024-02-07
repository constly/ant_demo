local ecs = ...
local ImGui     = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_10_system",
    category        = mgr.type_core,
    name            = "10_输入",
    file            = "core/core_10.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w
local icamera = ecs.require "ant.camera|camera"
local math3d = require "math3d"
local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.render|components.entity"

local ivs = ecs.require "ant.render|visible_state"
local ianimation = ecs.require "ant.animation|animation"
local iplayback = ecs.require "ant.animation|playback"

local e_light = nil;
local e_plane = nil
local ins_girl = nil
local entities

function system.on_entry()
	-- prefab中可以有多个实体
	-- 返回entity id数组
	e_light = world:create_instance {
        prefab = "/pkg/game.res/light.prefab"
    }

	-- 返回entity id
	e_plane = world:create_entity{
		policy = {
			"ant.render|simplerender",
		},
		data = {
			scene 		= {
				s = {250, 1, 250},
            },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible_state= "main_view",
			simplemesh 	= imesh.init_mesh(ientity.plane_mesh()),
			on_ready = function(e)
				print("create plane complete", e)
			end,
		}
	}

	ins_girl = world:create_instance {
		prefab = "/pkg/game.res/npc/test_001/test_001.glb|mesh.prefab",
        on_ready = function ()
            local main_queue = w:first "main_queue camera_ref:in"
            local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
            local dir = math3d.vector(0, -1, 1)

			local boxcorners = {math3d.vector(-1.0, -1.0, -1.0), math3d.vector(1.0, 1.0, 1.0)}
			local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
			icamera.focus_aabb(main_camera, aabb, dir)
			
            -- if not icamera.focus_prefab(main_camera, entities, dir) then
            --     error "aabb not found"
            -- end
        end
    }
    entities = ins_girl.tag['*']
end

function system.on_leave()
	world:remove_entity(e_plane)
	world:remove_instance(e_light)
	world:remove_instance(ins_girl)
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())

    if ImGui.Begin("entities", nil, ImGui.WindowFlags {"AlwaysAutoResize", "NoMove", "NoTitleBar"}) then
        local animation_eid
        if ImGui.TreeNode "mesh" then
            for i = 1, #entities do
                local eid = entities[i]
                local e <close> = world:entity(eid, "render_object?in animation?in")
                if e.render_object then
                    local value = { ivs.has_state(e, "main_view") }
                    if ImGui.Checkbox(""..eid, value) then
                        ivs.set_state(e, "main_view", value[1])
                        ivs.set_state(e, "cast_shadow", value[1])
                    end
                end
                if e.animation then
                    animation_eid = eid
                end
            end
            ImGui.TreePop()
        else
            for i = 1, #entities do
                local eid = entities[i]
                local e <close> = world:entity(eid, "animation?in")
                if e.animation then
                    animation_eid = eid
                end
            end
        end
        if animation_eid and ImGui.TreeNodeEx("animation", ImGui.TreeNodeFlags {"DefaultOpen"}) then
            local e <close> = world:entity(animation_eid, "animation:in")
            local animation = e.animation
            for name, status in pairs(animation.status) do
                if ImGui.TreeNode(name) then
                    do
                        local v = { status.play }
                        if ImGui.Checkbox("play", v) then
                            iplayback.set_play(e, name, v[1])
                        end
                    end
                    if ImGui.RadioButton("hide", iplayback.get_completion(e, name) == "hide") then
                        iplayback.completion_hide(e, name)
                    end
                    if ImGui.RadioButton("loop", iplayback.get_completion(e, name) == "loop") then
                        iplayback.completion_loop(e, name)
                    end
                    if ImGui.RadioButton("stop", iplayback.get_completion(e, name) == "stop") then
                        iplayback.completion_stop(e, name)
                    end
                    do
                        local value = { status.speed and math.floor(status.speed*100) or 100 }
                        if ImGui.DragIntEx("speed", value, 5.0, 0, 500, "%d%%") then
                            iplayback.set_speed(e, name, value[1] / 100)
                        end
                    end
                    do
                        local value = { status.weight }
                        if ImGui.SliderFloat("weight", value, 0, 1) then
                            ianimation.set_weight(e, name, value[1])
                        end
                    end
                    do
                        local value = { status.ratio }
                        if ImGui.SliderFloat("ratio", value, 0, 1) then
                            ianimation.set_ratio(e, name, value[1])
                        end
                    end
                    ImGui.TreePop()
                end
            end
            ImGui.TreePop()
        end
    end
    ImGui.End()
end