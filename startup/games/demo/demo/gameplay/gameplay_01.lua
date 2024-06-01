local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "gameplay_01_system",
    category        = mgr.type_gameplay,
    name            = "01_3D寻路",
    file            = "gameplay/gameplay_01.lua",
	ok 				= true
}
local system 		= mgr.create_system(tbParam)

local dep = require "dep" ---@type demo.dep
local ImGui = dep.ImGui
local world = ecs.world
local w = world.w
local imesh = ecs.require "ant.asset|mesh"
local ientity = ecs.require "ant.entity|entity"
local PC  = ecs.require("utils.world_handler").proxy_creator()
local iom = ecs.require "ant.objcontroller|obj_motion"
local iviewport = ecs.require "ant.render|viewport.state"
local ipu = ecs.require "ant.objcontroller|pickup.pickup_system"
local icamera = ecs.require "ant.camera|camera"
local math3d = require "math3d"

---@type ly.common
local common = import_package 'ly.common'

---@type ly.game_editor.editor
local editor 

---@type ly.game_core
local game_core = import_package 'ly.game_core'

---@type ly.world.main
local ly_world = import_package 'ly.world'
local grid_def = ly_world.get_grid_def()

local c_world
local grid_instances = {}
local hint_instance = {}

local topick_mb
local pickup_mb
local last_entity

--- 是不是编辑器模式
local is_editor_mode = false


function system.on_entry()
	topick_mb = world:sub{"mouse", "LEFT"}
	pickup_mb = world:sub{"pickup"}

	editor = require 'designer.editor'
	editor.browse_and_open("/pkg/demo.res/designer/nav/map.map")

	PC:create_instance { 
		prefab = "/pkg/demo.res/light_skybox.prefab",
		on_ready = function(e)
			local main_queue = w:first "main_queue camera_ref:in"
			local main_camera <close> = world:entity(main_queue.camera_ref, "camera:in")
			local dir = math3d.vector(0, -1, 1)
			local size = 4
			local boxcorners = {math3d.vector(-size, -size, -size), math3d.vector(size, size, size)}
			local aabb = math3d.aabb(boxcorners[1], boxcorners[2])
			icamera.focus_aabb(main_camera, aabb, dir)
		end 
	}
	c_world = ly_world.create_world()
	system.load_map()
end

function system.on_leave()
	world:unsub(topick_mb)
	world:unsub(pickup_mb)
	c_world:Destroy()
	c_world = nil
	last_entity = nil
	editor.save()
	PC:clear()
	system.destroy_grid_instances()
end

function system.data_changed()
	local pos_x, pos_y = mgr.get_content_start()
	local height = 45
	ImGui.SetNextWindowPos(pos_x, pos_y)
	ImGui.SetNextWindowSize(200, height)

	if ImGui.Begin("title", nil, ImGui.WindowFlags {"NoMove", "NoTitleBar", "NoResize"}) then 
		if common.imgui_utils.draw_btn("场 景 ## btn_scene", not is_editor_mode, {size_x = 80}) then 
			is_editor_mode = false;
			system.load_map()
		end
		ImGui.SameLine()
		if common.imgui_utils.draw_btn("编辑器## btn_scene", is_editor_mode, {size_x = 80}) then 
			is_editor_mode = true;
		end
	end
	ImGui.End()

	if is_editor_mode then 
		pos_y = pos_y + height
		ImGui.SetNextWindowPos(pos_x, pos_y)

		local size_x, size_y = mgr.get_content_size()
		ImGui.SetNextWindowSize(size_x, size_y - height)

		if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
			editor.default_draw(10, 10)
		end 
		ImGui.End()
	else 
		for _, _, state, x, y in topick_mb:unpack() do
			if state == "DOWN" then
				system.set_scale(last_entity, 1)
				x, y = iviewport.remap_xy(x, y)
				ipu.pick(x, y, function(e, a, b)
				end)
			end
		end
	end
end

function system.load_map()
	---@type map<number, sims.grid_def.line>
	local tbGridDef = {}
	do 
		local lines = common.file.load_csv("/pkg/demo.res/designer/nav/map_def.txt")
		for i, line in ipairs(lines) do 
			local id = tonumber(line.id) or 0
			if id > 0 then 
				local tb = {} ---@type sims.grid_def.line
				tb.id = id 
				tb.name = line.name
				tb.size = common.lib.eval(line.size)
				tb.model = line.model
				tb.scale = common.lib.eval(line.scale) or {1, 1, 1}
				tb.className = line.className
				tb.param1 = line.param1
				tb.param2 = line.param2
				tbGridDef[id] = tb
			end
		end
	end

	---@type chess_data_handler
	local data_handler
	do 
		local datalist = common.file.load_datalist("/pkg/demo.res/designer/nav/map.map")
		data_handler = game_core.create_map_handler()
		data_handler.init(datalist)
	end

	c_world:Reset()
	system.destroy_grid_instances()
	for _, layer in ipairs(data_handler.data.region.layers) do 
		local y = math.floor(layer.height)
		for gridId, grid in pairs(layer.grids) do 
			local def = tbGridDef[grid.tpl]
			if def and def.model then
				local x, z = data_handler.grid_id_to_grid_pos(gridId)
				local instance = world:create_instance {
					prefab = def.model .. "/mesh.prefab",
					on_ready = function(e)
						local eid = e.tag['*'][1]
						assert(eid, string.format("failed to create create_instance, model = %s", def.model))
						local ee<close> = world:entity(eid)
						iom.set_position(ee, math3d.vector(x, y, z))
						iom.set_scale(ee, def.scale)
					end
				}
				table.insert(grid_instances, instance)
				c_world:SetGridData(x, y, z, def.size[1] or 1, def.size[2] or 1, def.size[3] or 1, grid_def.Under_Ground)
			end 
		end 
	end
end

function system.destroy_grid_instances()
	for _, p in ipairs(grid_instances) do
		world:remove_instance(p)
	end
	grid_instances = {}
end

function system.set_scale(eid, scale)
	eid = tonumber(eid)
	if not eid then return end 

	local ee<close> = world:entity(eid)
	if ee then 
		iom.set_scale(ee, scale)
	end
end

function system.after_pickup()
	for _, eid, x, y in pickup_mb:unpack() do 
		system.set_scale(eid, 0.8)
		last_entity = eid
		break
	end
end