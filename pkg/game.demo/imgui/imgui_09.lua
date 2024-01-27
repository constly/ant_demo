local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_09_system",
    category        = mgr.type_imgui,
    name            = "09_自定义绘制",
    file            = "imgui/imgui_09.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local thickness = 3.0;

function system.data_changed()
    
    ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 

    end
    ImGui.End()
end