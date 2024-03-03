---@class ly.map.chess.dep
local dep = {}

-- 系统依赖
dep.ImGui  			= require "imgui"

-- 项目依赖
dep.common 			= import_package 'ly.common' 			---@type ly.common.main
dep.ImGuiExtend		= require "ly.imgui.extend"
dep.ed 				= require "ly.imgui.node_editor"  		---@type blueprint_ed

return dep