---------------------------------------------------------------------------
--- 依赖的包
---------------------------------------------------------------------------

---@class ly.node.blueprint.dep
local dep = {}

-- 系统依赖
dep.ImGui  			= require "imgui"
dep.assetmgr		= import_package "ant.asset"
dep.textureman 		= require "textureman.client"
dep.serialize 		= import_package "ant.serialize"
dep.fs  			= require "filesystem"

-- 项目依赖
dep.common 			= import_package 'ly.common' 		---@type ly.common
dep.ed 				= require "ly.imgui.node_editor"
dep.ImGuiExtend		= require "ly.imgui.extend"

return dep