
local dep = {}  ---@class ly.game_editor.dep

--- 系统依赖
dep.ImGui  			= require "imgui"
dep.serialize 		= import_package "ant.serialize"
dep.fs  			= require "filesystem"
dep.bfs 			= require "bee.filesystem"
dep.datalist		= require 'datalist'
dep.assetmgr  		= import_package "ant.asset"
dep.textureman 		= require "textureman.client"
dep.fastio 			= require "fastio"
dep.json 			= import_package "ant.json"

--- 项目依赖
dep.ImGuiExtend 	= require "ly.imgui.extend"

---@type ly.common
dep.common 			= import_package 'ly.common' 	

---@type blueprint_ed
dep.ed 				= require "ly.imgui.node_editor"  		

return dep