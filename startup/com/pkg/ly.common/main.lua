---------------------------------------------------------------------------
--- 一些工具组件
---------------------------------------------------------------------------

---@class ly.common.main
local api = {}
api.lib         	= require 'tools/lib'
api.user_data   	= require 'tools/user_data'
api.imgui_utils 	= require 'imgui/imgui_utils'		---@type ly.common.imgui_utils
api.imgui_styles 	= require 'imgui/imgui_styles'		---@type ly.common.imgui_styles

api.data_stack 		= require 'stack/data_stack'		---@type common_data_stack
api.path_def 		= require 'path_def'  				---@type ly.common.path_def

return api