---@class ly.map.chess.dep
local dep = {}

-- 系统依赖

-- 项目依赖
dep.common 			= import_package 'ly.common' 		---@type ly.common.main
dep.ImGuiExtend		= require "ly.imgui.extend"

return dep