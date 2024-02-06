local ecs = ...
local ImGui     = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_03_system",
    category        = mgr.type_core,
    name            = "03_luamake",
    file            = "core/core_03.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)


function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("工程编译相关")
	end 
	ImGui.End()
end
	