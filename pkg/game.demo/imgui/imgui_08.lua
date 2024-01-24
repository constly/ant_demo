local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local system = mgr.create_system(ecs, "imgui_08_system", mgr.type_imgui, "08_复制/粘贴", "尚未实现")

function system.data_changed()
    

end