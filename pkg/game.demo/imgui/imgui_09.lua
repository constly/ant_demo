local ecs = ...
local system = ecs.system "imgui_09_system"
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local id = mgr.register(system, mgr.type_imgui, "09_自定义绘制", "尚未实现")

function system:data_changed()
    if id ~= mgr.get_current_id() then return end 
end