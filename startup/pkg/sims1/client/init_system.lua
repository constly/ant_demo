local ecs = ...
local system = ecs.system "init_system"
local world = ecs.world
local w = world.w
local dep 			= require 'client.dep' ---@type sims1.dep
local ImGui 		= dep.ImGui
local expand = false
local editor  ---@type ly.game_editor.editor

local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"
local math3d = require "math3d"
local icamera = ecs.require "ant.camera|camera"

function system.preinit()
	---@type sims1.client
	Sims1 = require 'client.client'.new(ecs)
end 

function system.init()
	Sims1.start()

	print("system.init")
	local fonts = {}
	fonts[#fonts+1] = {
		FontPath = "/pkg/ant.resources.binary/font/Alibaba-PuHuiTi-Regular.ttf",
		SizePixels = 18,
		GlyphRanges = { 0x0020, 0xFFFF }
	}
	local ImGuiAnt  = import_package "ant.imgui"
	ImGuiAnt.FontAtlasBuild(fonts)	
end 

function system.exit()
	Sims1.shutdown()
	Sims1 = nil
	if editor then 
		editor.exit()
		editor = nil
	end
end


function system.init_world()
	print("system.init_world")
	
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

	-- local iom = ecs.require "ant.objcontroller|obj_motion"
	-- for i = 1, 5 do 
	-- 	world:create_instance {
	-- 		prefab = "/pkg/game.res/npc/cube/cube_green.glb/mesh.prefab",
	-- 		on_ready = function(e)
	-- 			local eid = e.tag['*'][1]
	-- 			local ee<close> = world:entity(eid)
	-- 			iom.set_position(ee, math3d.vector(i * 2.5 - 10, 0, 0))
	-- 		end
	-- 	}
	-- end

	local main_queue = w:first "main_queue camera_ref:in"
	local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
	local dir = math3d.vector(0, -1, 1)
	local size = 4
	local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
	local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
	icamera.focus_aabb(main_camera, aabb, dir)
end



function system.data_changed()
	--Sims1.call_server(msg.rpc_ping, {v = "2"})
	ImGui.SetNextWindowPos(0, 0)
	local dpi = ImGui.GetMainViewport().DpiScale
	if expand then 
		local viewport = ImGui.GetMainViewport();
    	local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
		ImGui.SetNextWindowSize(size_x, size_y);
	else 
		ImGui.SetNextWindowSize(170 * dpi, 40 * dpi);
	end
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		if dep.common.imgui_utils.draw_btn(" 返 回 ", not expand) then 
			if expand then 
				expand = not expand
			else 
				Sims1.exitCB()
			end
		end
		ImGui.SameLine()
		if dep.common.imgui_utils.draw_btn("刷 新", false) then 
			Sims1.call_server(Sims1.msg.rpc_restart)
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
				tbParams.project_root = world.args.ecs.project_root
				tbParams.pkgs = {"sims1.res"}
				tbParams.theme_path = "sims1.res/themes/default.style"
				tbParams.goap_mgr = require 'goap.goap'
				editor = dep.game_editor.create_editor(tbParams)
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