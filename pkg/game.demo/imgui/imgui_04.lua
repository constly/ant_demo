local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local system = mgr.create_system(ecs, "imgui_04_system", mgr.type_imgui, "04_Table", "尚未实现")

function system.data_changed()
    

end