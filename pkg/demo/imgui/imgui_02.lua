local ecs = ...
local system = ecs.system "imgui_02_system"
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local id = mgr.register(system, mgr.type_imgui, "02_基础控件", "包括普通按钮，图片按钮，尚未实现")

function system:data_changed()
    if id ~= mgr.get_current_id() then return end 

end