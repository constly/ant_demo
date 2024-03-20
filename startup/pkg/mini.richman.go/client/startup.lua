local ecs = ...
local system 		= ecs.system "startup"
local dep 			= require 'client.dep' ---@type mini.richman.go.dep
local ImGui 		= dep.ImGui
local statemachine 	= require 'client.state_machine'  ---@type mini.richman.go.view.state_machine

local world = ecs.world
local w = world.w
local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"
local math3d = require "math3d"
local icamera = ecs.require "ant.camera|camera"
local expand = true
local editor  ---@type ly.game_editor.editor

function system.init()
	print("system.init")
end 

function system.post_init()
	print("system.post_init")
end

function system.init_world()
	print("system.init_world")
	statemachine.init(false, RichmanMgr.is_listen_player)

	world:create_instance { prefab = "/pkg/game.res/light_skybox.prefab" }
	-- world:create_entity{
	-- 	policy = { "ant.render|simplerender", },
	-- 	data = {
	-- 		scene = { s = {250, 1, 250}, },
	-- 		material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
	-- 		visible	= true,
	-- 		mesh_result = imesh.init_mesh(ientity.plane_mesh(), true),
	-- 		owned_mesh_buffer = true,
	-- 		on_ready = function(e) 
	-- 			local main_queue = w:first "main_queue camera_ref:in"
	-- 			local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
	-- 			local dir = math3d.vector(0, -1, 1)
	-- 			local size = 4
	-- 			local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
	-- 			local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
	-- 			icamera.focus_aabb(main_camera, aabb, dir)
	-- 		end,
	-- 	}
	-- }

	local iom = ecs.require "ant.objcontroller|obj_motion"
	for i = 1, 5 do 
		world:create_instance {
			prefab = "/pkg/game.res/npc/cube/cube_green.glb|mesh.prefab",
			on_ready = function(e)
				local eid = e.tag['*'][1]
				local ee<close> = world:entity(eid)
				iom.set_position(ee, math3d.vector(i * 2.5 - 10, 0, 0))
			end
		}
	end

	local main_queue = w:first "main_queue camera_ref:in"
	local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
	local dir = math3d.vector(0, -1, 1)
	local size = 4
	local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
	local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
	icamera.focus_aabb(main_camera, aabb, dir)
end

function system.exit()
	print("system.exit")
	statemachine.reset()
	if editor then 
		editor.exit()
	end
end

function system.data_changed()
	ImGui.SetNextWindowPos(0, 0)
	local dpi = ImGui.GetMainViewport().DpiScale
	if expand then 
		local viewport = ImGui.GetMainViewport();
    	local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
		ImGui.SetNextWindowSize(size_x, size_y);
	else 
		ImGui.SetNextWindowSize(120 * dpi, 40 * dpi);
	end
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		if dep.common.imgui_utils.draw_btn(" 返 回 ", not expand) then 
			if expand then 
				expand = not expand
			else 
				RichmanMgr.exitCB()
			end
		end
		ImGui.SameLine()
		if dep.common.imgui_utils.draw_btn("编辑器", expand) then 
			expand = not expand
		end
		if expand then 
			if not editor then 
				---@type ly.game_editor.create_params
				local tbParams = {}
				tbParams.module_name = "richmango"
				tbParams.pkgs = {"mini.richman.res"}
				editor = dep.game_editor.create(tbParams)
			end
			local x, y = ImGui.GetContentRegionAvail()
			ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 0, 0)
			ImGui.BeginChild("ImGui.BeginChild", x, y, ImGui.ChildFlags({"Border"}))
			editor.draw()
			ImGui.EndChild()
			ImGui.PopStyleVar()
		end
	end 
	ImGui.End()
end