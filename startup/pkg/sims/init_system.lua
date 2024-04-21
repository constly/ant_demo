local ecs = ...
local system = ecs.system "init_system"
local world = ecs.world
local w = world.w

local ImGui 		= require "imgui"
---@type ly.common
local common 		= import_package 'ly.common' 	
---@type ly.game_editor	
local game_editor  	= import_package 'ly.game_editor'
---@type ly.game_editor.editor
local editor  
local expand = false

local math3d = require "math3d"
local icamera = ecs.require "ant.camera|camera"
local client

function system.preinit()
	---@type sims.client
	client = require 'client'.new(ecs)
end 

function system.init()
	client.start()

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
	client.shutdown()
	client = nil
	if editor then 
		editor.exit()
		editor = nil
	end
end


function system.init_world()
	print("system.init_world")	
	world:create_instance { prefab = "/pkg/game.res/light_skybox.prefab" }

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
		ImGui.SetNextWindowSize(120 * dpi, 40 * dpi);
	end
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		if common.imgui_utils.draw_btn(" 返 回 ", not expand) then 
			if expand then 
				expand = not expand
			else 
				client.exitCB()
			end
		end
		ImGui.SameLine()
		if common.imgui_utils.draw_btn("编辑器", expand) then 
			expand = not expand
			if not expand then 
				client.call_server(client.msg.rpc_restart)
			end
		end
		if expand then 
			if not editor then 
				---@type ly.game_editor.create_params
				local tbParams = {}
				tbParams.module_name = "richmango"
				tbParams.project_root = world.args.ecs.project_root
				tbParams.pkgs = {"sims.res"}
				tbParams.theme_path = "sims.res/themes/default.style"
				tbParams.goap_mgr = require 'goap.goap'
				tbParams.menus = {
					{name = "存档辅助", window = require 'debug.wnd_saved'.new() },
				}
				editor = game_editor.create_editor(tbParams)
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