---@class ly.common.dep
local dep = {}

dep.fs 				= require "bee.filesystem"
dep.ImGui  			= require "imgui"
dep.datalist		= require 'datalist'
dep.aio 			= import_package "ant.io"

return dep;