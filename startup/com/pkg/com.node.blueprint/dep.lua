---------------------------------------------------------------------------
--- 依赖的包
---------------------------------------------------------------------------

local dep = {}

dep.common 		= import_package 'com.common' 		---@type com.common.main
dep.ImGui  		= require "imgui"
dep.ed 			= require "imgui.node_editor"

return dep