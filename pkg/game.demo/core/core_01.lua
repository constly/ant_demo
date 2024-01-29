local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_01_system",
    category        = mgr.type_core,
    name            = "01_3rd说明",
    file            = "core/core_01.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		-- 列出用了哪些三方库，以及每个库的作用，地址，教程等
	end
	ImGui.End()
end