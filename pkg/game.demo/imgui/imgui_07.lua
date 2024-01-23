local ecs = ...
local system = ecs.system "imgui_07_system"
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local id = mgr.register(system, mgr.type_imgui, "07_撤销/回退", "尚未实现")

function system:data_changed()
    if id ~= mgr.get_current_id() then return end 

end