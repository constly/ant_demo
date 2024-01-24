local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local system = mgr.create_system(ecs, "imgui_03_system", mgr.type_imgui, "03_窗口", "尚未实现")

function system.data_changed()
    

end