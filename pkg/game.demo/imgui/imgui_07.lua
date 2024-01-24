local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local system = mgr.create_system(ecs, "imgui_07_system", mgr.type_imgui, "07_撤销/回退", "尚未实现")

function system.data_changed()
    

end