---------------------------------------------------------------------------
--- 一些工具组件
---------------------------------------------------------------------------

---@class ly.common
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
api.data_stack 		= require 'tools.data_stack'		

---@type ly.common.path_def
api.path_def 		= require 'path_def'  				

---@type ly.common.map
api.map 			= require 'tools.map'					

---@type ly.common.file
api.file 			= require 'tools.file'			

---@type ly.common.datalist
api.datalist 		= require 'tools.datalist'

---@return goap_mgr
function api.new_goap_mgr()
	local mgr = require 'goap.goap_mgr'
	return mgr.new()
end

---@return ly.common.timer
function api.new_timer()
	local timer = require 'tools.timer'
	return timer.new()
end

return api