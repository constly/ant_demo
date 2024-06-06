local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "scene_03_system",
    category        = mgr.type_scene,
    name            = "03_怪潮",
    file            = "scene/scene_03.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w

local mathpkg= import_package "ant.math"
local mc    = mathpkg.constant

local math3d = require "math3d"
local iai   = ecs.require "ant.animation_instances|animation_instances"
local timer = ecs.require "ant.timer|timer_system"
local iom   = ecs.require "ant.objcontroller|obj_motion"
local imesh   = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"

local PC  = ecs.require("utils.world_handler").proxy_creator()

local abo
local bakenum<const> = 30

local function many_instances(prefab)
    local s = 0.02
    local dx, dz = 2, 1
    local instances = {}

    local h = 0

    local numx, numz = 16, 32
    local half_numx, half_numz = numx//2, (numz//2) * 0.5

    for i=1, numz do
        local z = ((i-1)-half_numz)*dz
        for j=1, numx do
            local x = ((j-1)-half_numx)*dx

            instances[#instances+1] = {
                frame   = math.random(0, bakenum-1),
                s       = s,
                t       = {x + dx*math.random()*0.5, h, z+dz*math.random()*0.5, 1},
                r       = {0, math.pi*math.random(-30, 30)*0.1, 0},
            }
        end
    end

    return iai.create(prefab, bakenum, #instances, instances)
end


local kb_mb = world:sub{"keyboard"}

local move_animation_instances; do
    local move_time_ms = 0
    local offset = 0
    local move_delta_ms
    function move_animation_instances()
        local bo = abo.Armature_Take_001_BaseLayer
        if nil == move_delta_ms then
            local re = world:entity(bo.render, "animation_instances:in")
            local f = re.animation_instances.frame
            local durationms = f.duration * 1000
            move_delta_ms = durationms / f.num
        end
        local d = timer.delta()
        if move_time_ms >= move_delta_ms then
            iai.update_offset(bo, offset)

            offset = (offset+1) % bakenum
            move_time_ms = move_time_ms - move_delta_ms
        else
            move_time_ms = move_time_ms + d
        end
    end
end


function system.on_entry()
	do return end
	
    local mq = w:first "main_queue camera_ref:in"
    local ce<close> = world:entity(mq.camera_ref)
    local eyepos = math3d.vector(0, 15,-10)
    iom.set_position(ce, eyepos)
    local dir = math3d.normalize(math3d.sub(mc.ZERO_PT, eyepos))
    iom.set_direction(ce, dir)

	abo = many_instances "/pkg/demo.res/npc/zombies/5-normal1.glb/ani_bake.prefab"
	local function create_shadow_plane(sx, sz)
		sz = sz or sx
		return PC:create_entity{
			policy = {
				"ant.render|render",
			},
			data = {
				scene 		= {s = {sx, 1, sz},},
				mesh = "plane.primitive",
				material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
				visible     = true,
			}
		}
	end
	create_shadow_plane(50, 50)
end

local rotate_directional_light; do
    local FIVE_SECOND<const> = 5000
    local move_delta_ms = 0
    function rotate_directional_light()
        local dl = w:first "directional_light light:in scene:update"
        if dl then
            local d = timer.delta()
            move_delta_ms = (move_delta_ms + d) % FIVE_SECOND
            local dir = math3d.normalize(math3d.vector(-1, -1, -1))
            local t = move_delta_ms / FIVE_SECOND
            local rad = 2*math.pi*t
            iom.set_direction(dl, math3d.transform(math3d.quaternion{axis=math3d.vector(0, 1, 0), r=rad}, dir, 0))
            
            w:submit(dl)
        end
    end
end

local move_offset = 1

function system.data_changed()
    if abo then
        for _, key, press in kb_mb:unpack() do
            if press == 0 and key == "C" then
                iai.update_offset(assert(abo.Armature_Take_001_BaseLayer), move_offset)
                move_offset = (move_offset + 1) % bakenum
            end
        end

       move_animation_instances()
        rotate_directional_light()
    end
end

function system.on_leave()
    if abo then
        iai.destroy(abo)
		abo = nil
    end
    PC:clear()
end