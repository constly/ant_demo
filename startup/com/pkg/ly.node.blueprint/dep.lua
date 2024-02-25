---------------------------------------------------------------------------
--- 依赖的包
---------------------------------------------------------------------------

local dep = {}

dep.common 			= import_package 'ly.common' 		---@type ly.common.main
dep.ed 				= require "ly.imgui.node_editor"
dep.ImGui  			= require "imgui"

return dep