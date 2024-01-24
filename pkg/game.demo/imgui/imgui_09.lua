local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local system = mgr.create_system(ecs, "imgui_09_system", mgr.type_imgui, "09_自定义绘制", "尚未实现")

function system.data_changed()
    

end