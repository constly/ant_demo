
local dep = {}  ---@class ly.game_editor.dep

--- 系统依赖
dep.ImGui  		= require "imgui"

--- 项目依赖
---@type ly.common.main
dep.common 		= import_package 'ly.common' 	

return dep