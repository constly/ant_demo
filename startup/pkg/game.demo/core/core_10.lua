local ecs = ...
local ImGui     = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_10_system",
    category        = mgr.type_core,
    name            = "10_模型浏览",
    file            = "core/core_10.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w
local icamera = ecs.require "ant.camera|camera"
local math3d = require "math3d"
local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"

local dep = require "dep"
local vfs = require "vfs"
local lfs = require "bee.filesystem"
local irender       = ecs.require "ant.render|render"
local ianimation = ecs.require "ant.animation|animation"
local iplayback = ecs.require "ant.animation|playback"

local e_light = nil;
local e_plane = nil
local ins_model = nil
local entities = {}

local model_index 
local glbs

function system.on_entry()
	e_light = world:create_instance { prefab = "/pkg/game.res/light_skybox.prefab" }
	e_plane = world:create_entity{
		policy = { "ant.render|simplerender", },
		data = {
			scene = { s = {250, 1, 250}, },
			material 	= "/pkg/ant.resources/materials/mesh_shadow.material",
			visible	= true,
			mesh_result = imesh.init_mesh(ientity.plane_mesh(), true),
			owned_mesh_buffer = true,
		}
	}

	-- 遍历得到目录下所有glb文件
	glbs = {}
	if vfs.repopath then
		local repo = vfs.repopath()
		local pkg_name = "/pkg/game.res"
		local root = repo .. pkg_name 
		local files = {}
		system.get_all_files(root, files)
		local tb_ext = {".glb", ".gltf"}
		for _, path in ipairs(files) do 
			for _, ext in ipairs(tb_ext) do 
				if dep.common.lib.end_with(path, ext) then 
					local path = string.gsub(path, repo, "");
					local shortpath = string.gsub(path, pkg_name, "")
					local name = dep.common.lib.get_file_name(shortpath)
					table.insert(glbs, {name = name, tip = path, path = path .. "/mesh.prefab"})
					break;
				end
			end
		end
	else 
		glbs[1] = {name = "运行时版本不支持"}
	end
	table.sort(glbs, function (a, b) return a.name < b.name end)
	--dep.common.lib.dump(glbs)
	system.show_model(model_index or 1)
end

function system.get_all_files(root, rets)
	for file in lfs.pairs(root) do
		if file ~= "." and file ~= ".." then
			if lfs.is_directory(file) then 
				system.get_all_files(file, rets)
			else 
				rets[#rets + 1] = tostring(file)
			end
		end
	end
end

function system.on_leave()
	world:remove_entity(e_plane)
	world:remove_instance(e_light)
	if ins_model then 
		world:remove_instance(ins_model)
	end
end

function system.data_changed()
	system.draw_filelist()
	system.draw_anim()
end

function system.show_model(index)
	model_index = index
	local data = glbs[index]
	if not data or not data.path then return end 
	if ins_model then world:remove_instance(ins_model) end

	local mathpkg   = import_package "ant.math"
	local mc    = mathpkg.constant
	ins_model = world:create_instance {
		prefab = data.path,
        on_ready = function ()
            local main_queue = w:first "main_queue camera_ref:in"
            local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
            local dir = math3d.vector(0, -1, 1)
			local aabb
			for i = 1, #entities do
				local e = entities[i]
				local ec <close> = world:entity(e, "bounding?in")
				local bounding = ec.bounding
				if bounding and bounding.scene_aabb ~= mc.NULL then
					if not aabb then
						aabb = bounding.scene_aabb
					else
						aabb = math3d.aabb_merge(bounding.scene_aabb, aabb)
					end
				end
			end
			if aabb then
				local aabb_min, aabb_max = math3d.tovalue(math3d.array_index(aabb, 1)), math3d.tovalue(math3d.array_index(aabb, 2))
				local delta_x = math.abs(aabb_min[1] - aabb_max[1])
				local delta_y = math.abs(aabb_min[2] - aabb_max[2])
				local delta_z = math.abs(aabb_min[3] - aabb_max[3])
				local value = math.max(delta_x, delta_y, delta_z)
				if value < 1 then 
					aabb = nil
				end
			end

			if aabb then 
				icamera.focus_aabb(main_camera, aabb, dir)
			else 
				local aabb = math3d.aabb(math3d.vector(-1.0, -1.0, -1.0), math3d.vector(1.0, 1.0, 1.0))
				icamera.focus_aabb(main_camera, aabb, dir)
			end
        end
    }
    entities = ins_model.tag['*']
end

function system.draw_filelist()
	local posx, posy = mgr.get_content_start()
	local sizex, sizey = mgr.get_content_size()
	local set_btn_style = function(current)
		if current then 
			ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0, 0.5, 0.8, 1)
			ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0, 0.55, 0.7, 1)
			ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0, 0.55, 0.7, 1)
		else 
			ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
			ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
			ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
		end
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
	end

	local btn_size = 200
	ImGui.SetNextWindowPos(sizex, posy)
	ImGui.SetNextWindowSize(btn_size, sizey)
	if ImGui.Begin("wnd_filelist", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoCollapse", "NoTitleBar"}) then 
		for i, data in ipairs(glbs) do 
			set_btn_style(i == model_index)
			local label = string.format("%d. %s##btn_file_%d", i, data.name, i)
			if ImGui.ButtonEx(label, btn_size - 10) then 
				system.show_model(i)
			end
			if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
				ImGui.Text(data.path or "")
				ImGui.EndTooltip()
			end
			ImGui.PopStyleColorEx(3)
			ImGui.PopStyleVar()
		end
	end 
	ImGui.End()
end

function system.draw_anim()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    if ImGui.Begin("wnd_entities", nil, ImGui.WindowFlags {"AlwaysAutoResize", "NoMove", "NoTitleBar"}) then
        ImGui.Text("浏览pkg/game.res目录下的模型\n如有需要, 请自行将vaststars工程里面\n的资源拷贝到game.res下")
		local animation_eid = {}
        if ImGui.TreeNode "mesh" then
            for i = 1, #entities do
                local eid = entities[i]
                local e <close> = world:entity(eid, "render_object?in animation?in visible?in")
                if e.render_object then
					local value = { e.visible }
                    if ImGui.Checkbox(""..eid, value) then
                        irender.set_visible(e, value[1])
                    end
                end
                if e.animation then
                    table.insert(animation_eid,  eid)
                end
            end
            ImGui.TreePop()
        else
            for i = 1, #entities do
                local eid = entities[i]
                local e <close> = world:entity(eid, "animation?in")
                if e and e.animation then
                    table.insert(animation_eid, eid)
					break
                end
            end
        end
        if #animation_eid > 0 and ImGui.TreeNodeEx("animation", ImGui.TreeNodeFlags {"DefaultOpen"}) then
            local e <close> = world:entity(animation_eid[1], "animation:in")
            local animation = e.animation

			local set_play = function(list, name, value)
				for _, v in ipairs(list) do 
					local e <close> = world:entity(v, "animation:in")
					iplayback.set_play(e, name, value)
				end
			end
			local completion_hide = function(list, name)
				for _, v in ipairs(list) do 
					local e <close> = world:entity(v, "animation:in")
					iplayback.completion_hide(e, name)
				end
			end
			local completion_loop = function(list, name)
				for _, v in ipairs(list) do 
					local e <close> = world:entity(v, "animation:in")
					iplayback.completion_loop(e, name)
				end
			end
			local completion_stop = function(list, name, value)
				for _, v in ipairs(list) do 
					local e <close> = world:entity(v, "animation:in")
					iplayback.completion_stop(e, name, value)
				end
			end
			local set_speed = function(list, name, value)
				for _, v in ipairs(list) do 
					local e <close> = world:entity(v, "animation:in")
					iplayback.set_speed(e, name, value)
				end
			end
			local set_weight = function(list, name, value)
				for _, v in ipairs(list) do 
					local e <close> = world:entity(v, "animation:in")
					ianimation.set_weight(e, name, value)
				end
			end
			local set_ratio = function(list, name, value)
				for _, v in ipairs(list) do 
					local e <close> = world:entity(v, "animation:in")
					ianimation.set_ratio(e, name, value)
				end
			end

            for name, status in pairs(animation.status) do
                if ImGui.TreeNode(name) then
                    do
                        local v = { status.play }
                        if ImGui.Checkbox("play", v) then
                            set_play(animation_eid, name, v[1])
                        end
                    end
                    if ImGui.RadioButton("hide", iplayback.get_completion(e, name) == "hide") then
                        completion_hide(animation_eid, name)
                    end
                    if ImGui.RadioButton("loop", iplayback.get_completion(e, name) == "loop") then
                        completion_loop(animation_eid, name)
                    end
                    if ImGui.RadioButton("stop", iplayback.get_completion(e, name) == "stop") then
                        completion_stop(animation_eid, name)
                    end
                    do
                        local value = { status.speed and math.floor(status.speed*100) or 100 }
                        if ImGui.DragIntEx("speed", value, 5.0, 0, 500, "%d%%") then
                            set_speed(animation_eid, name, value[1] / 100)
                        end
                    end
                    do
                        local value = { status.weight }
                        if ImGui.SliderFloat("weight", value, 0, 1) then
                            set_weight(animation_eid, name, value[1])
                        end
                    end
                    do
                        local value = { status.ratio }
                        if ImGui.SliderFloat("ratio", value, 0, 1) then
                            set_ratio(animation_eid, name, value[1])
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