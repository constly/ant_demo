local ecs = ...
local ImGui = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_13_system",
    category        = mgr.type_core,
    name            = "13_WorldDebug",
    file            = "core/core_13.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local world = ecs.world
local w = world.w
local draw_world_state = require "utils.draw_world_state"
local luaecs = import_package "ant.luaecs"
local vfs = require "vfs"
local showtip
local path = vfs.repopath() .. '.app/temp/world_core_13.bin'

function system.on_entry()
end 

function system.on_leave()
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
	ImGui.SetNextWindowSize(mgr.get_content_size())
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 

		ImGui.SetCursorPos(200, 100)
		ImGui.BeginGroup()
		if ImGui.ButtonEx("打开: World Dump", 200, 60) then 
			draw_world_state.open()
		end

		if ImGui.ButtonEx("将World写入到文件", 200, 60) then 
			system.write_world_to_file()
			showtip = true;
			os.execute("code ".. path)
		end
		if showtip then 
			ImGui.Text("文件存储至: " .. path)
		end
		--ImGui.Text("输出有多少entity, 多少system, 多少component, 占多少内存, 每帧耗时情况, 去3rd/luaecs下面找 ")

		ImGui.EndGroup()

		draw_world_state.draw(world)
	end 
	ImGui.End()
end

function system.write_world_to_file()
	
	luaecs.exporter.export(w, path)

	-- 遍历所有entity
	-- for v in w:select "eid:in" do
	-- 	print(v.eid)
	-- end
end