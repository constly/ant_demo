local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_09_system",
    category        = mgr.type_core,
    name            = "09_输入",
    file            = "core/core_09.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)
local world = ecs.world

local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.render|components.entity"

local pfb_light = nil;
local e_plane = nil

function system.on_entry()
	if pfb_light then return end 

	pfb_light = world:create_instance {
        prefab = "/pkg/game.res/light.prefab"
    }

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
		}
	}
end

function system.on_leave()
	if pfb_light then 
		-- 如何显示/隐藏 光照，地面
	end
end

function system.data_changed()
	-- ImGui.SetNextWindowPos(mgr.get_content_start())
    -- ImGui.SetNextWindowSize(mgr.get_content_size())
    -- if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
	-- 	ImGui.Text("待定")
	-- end 
	-- ImGui.End()
end