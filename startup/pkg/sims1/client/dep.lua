
local dep = {}  ---@class sims1.dep

--- 系统依赖
dep.ltask 		= require "ltask"
dep.window      = import_package "ant.window"
dep.ImGui  		= require "imgui"

--- 项目依赖
---@type ly.common.main
dep.common 		= import_package 'ly.common' 		

---@type ly.sound.main
dep.sound 		= import_package 'ly.sound'			

---@type ly.game_editor
dep.game_editor = import_package 'ly.game_editor'


return dep;