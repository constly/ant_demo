---------------------------------------------------------------------------
--- 依赖的包
---------------------------------------------------------------------------

---@class ly.node.blueprint.dep
local dep = {}

dep.common 			= import_package 'ly.common' 		---@type ly.common.main
dep.ed 				= require "ly.imgui.node_editor"
dep.ImGui  			= require "imgui"

dep.assetmgr		= import_package "ant.asset"
dep.textureman 		= require "textureman.client"

return dep