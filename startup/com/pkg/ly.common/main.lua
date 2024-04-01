---------------------------------------------------------------------------
--- 一些工具组件
---------------------------------------------------------------------------

---@class ly.common.main
local api = {}

---@type ly.common.lib
api.lib         	= require 'tools.lib'

---@type ly.common.user_data
api.user_data   	= require 'tools.user_data'

---@type ly.common.imgui_utils
api.imgui_utils 	= require 'imgui.imgui_utils'		

---@type ly.common.imgui_styles
api.imgui_styles 	= require 'imgui.imgui_styles'		

---@type common_data_stack
api.data_stack 		= require 'stack.data_stack'		

---@type ly.common.path_def
api.path_def 		= require 'path_def'  				

---@type ly.common.map
api.map 			= require 'map.map'					

---@type ly.common.file
api.file 			= require 'file.file'					

return api