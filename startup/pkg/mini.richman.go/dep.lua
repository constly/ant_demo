
local dep = {}  ---@class mini.richman.go.dep

--- 系统依赖
dep.ltask 		= require "ltask"
dep.window      = import_package "ant.window"
dep.ImGui  		= require "imgui"

--- 项目依赖
dep.common 		= import_package 'ly.common' 		---@type ly.common.main
dep.sound 		= import_package 'ly.sound'			---@type ly.sound.main
dep.chess_map 	= import_package 'ly.map.chess' 	---@type ly.map.chess.main


return dep;