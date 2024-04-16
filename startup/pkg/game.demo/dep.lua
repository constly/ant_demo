---------------------------------------------------------------------------
--- 依赖的包
---------------------------------------------------------------------------

---@class game.demo.dep
local dep = {}

--- 引擎依赖
dep.fs 				= require "bee.filesystem"
dep.vfs 			= require "vfs"
dep.datalist		= require 'datalist'
dep.ImGui  			= require "imgui"
dep.serialize 		= import_package "ant.serialize"
dep.net 			= import_package "ant.net"

--- 项目依赖
dep.ImGuiExtend 	= require "ly.imgui.extend"
dep.ed 				= require "ly.imgui.node_editor"  		---@type blueprint_ed
dep.common 			= import_package 'ly.common' 			---@type ly.common.main
dep.sound 			= import_package 'ly.sound'				---@type ly.sound.main
dep.blueprint 		= import_package "ly.node.blueprint"  	---@type ly.node.blueprint.main


return dep