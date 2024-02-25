---------------------------------------------------------------------------
--- 依赖的包
---------------------------------------------------------------------------

local dep = {}

dep.fs 				= require "bee.filesystem"
dep.vfs 			= require "vfs"

dep.ImGui  			= require "imgui"
dep.ImGuiExtend 	= require "ly.imgui.extend"
dep.ed 				= require "ly.imgui.node_editor"


dep.blueprint 		= import_package "ly.node.blueprint"  	---@type ly.node.blueprint.main
dep.common 			= import_package 'ly.common' 			---@type ly.common.main
dep.sound 			= import_package 'ly.sound'				---@type ly.sound.main



return dep