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
---@type sims.client
local client
local is_editor_dirty = false

---@type sims.debug.wnd_saved
local wnd_saved


function system.preinit()
	-- 设置项目根目录
	if world.args.ecs.project_root then
		common.path_def.project_root = world.args.ecs.project_root
	end
	client = require 'client'.new(ecs)
end 

function system.init()
	client.start()
	local fonts = {}
	fonts[#fonts+1] = {
		FontPath = "/pkg/ant.resources.binary/font/Alibaba-PuHuiTi-Regular.ttf",
		SizePixels = 18,
		GlyphRanges = { 0x0020, 0xFFFF }
	}
	local ImGuiAnt  = import_package "ant.imgui"
	ImGuiAnt.FontAtlasBuild(fonts)	
	expand = tonumber(common.user_data.get("sims.expand")) == 1
end 

function system.exit()
	client.shutdown()
	client = nil
	wnd_saved = nil
	if editor then 
		editor.exit()
		editor = nil
	end
end

function system.init_world()
	print("system.init_world")	
	world:create_instance { prefab = "/pkg/demo.res/light_skybox.prefab" }

	local main_queue = w:first "main_queue camera_ref:in"
	local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
	local dir = math3d.vector(0, -1, 1)
	local size = 4
	local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
	local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
	icamera.focus_aabb(main_camera, aabb, dir)
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
		if common.imgui_utils.draw_btn(" 主 页 ", not expand) then 
			if expand then 
				system.set_expand(not expand)
			else 
				client.exitCB()
			end
		end
		ImGui.SameLine()
		if common.imgui_utils.draw_btn("编辑器", expand) then 
			system.set_expand(not expand)
		end
		if expand then 
			if not editor then 
				wnd_saved = require 'debug.wnd_saved'.new(client)

				---@type ly.game_editor.create_params
				local tbParams = {}
				tbParams.module_name = "richmango"
				tbParams.project_root = common.path_def.project_root
				tbParams.pkgs = {"sims.res"}
				tbParams.theme_path = "sims.res/themes/default.style"
				tbParams.workspace_path = "/pkg/sims.res/space.work"
				tbParams.goap_mgr = require 'goap.goap'
				tbParams.menus = {
					{name = "存档助手", window = wnd_saved },
					{name = "开发计划", window = require 'debug.wnd_dev_plan'.new(client) },
				}
				tbParams.notify_file_saved = function(vfs_path, full_path)
					is_editor_dirty = true;
				end
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

function system.set_expand(v)
	expand = v
	common.user_data.set("sims.expand", expand and 1 or 0, true)
	if not expand and is_editor_dirty then 
		is_editor_dirty = false
		local type = wnd_saved and wnd_saved.get_restart_type()
		if type then
			client.call_server(client.msg.rpc_restart, {type = type})
		end
	end
end

-- function system.check_keyboard()
-- 	if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
-- 		if ImGui.IsKeyPressed(ImGui.Key.S, false) then 

-- 		end
-- 	end
-- end