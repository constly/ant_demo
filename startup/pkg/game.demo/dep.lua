---------------------------------------------------------------------------
--- 依赖的包
---------------------------------------------------------------------------

local dep = {}

dep.ImGui  			= require "imgui"
dep.ImGuiExtend 	= require "imgui.extend"
dep.blueprint 		= import_package "com.node.blueprint"  	---@type com.node.blueprint.main
dep.ed 				= require "imgui.node_editor"
dep.common 			= import_package 'com.common' 			---@type com.common.main

dep.fs 				= require "bee.filesystem"
dep.vfs 			= require "vfs"

return dep