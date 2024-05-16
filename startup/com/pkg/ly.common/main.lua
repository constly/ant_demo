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

---@type ly.common.net
api.net 			= require 'tools.net'

---@type ly.common.async
api.async 			= require 'tools.async'

---@return goap_mgr
function api.new_goap_mgr()
	local mgr = require 'goap.goap_mgr'
	return mgr.new()
end

--- 通过tick驱动的timer（更推荐使用这个）
---@return ly.common.tick_timer
function api.new_tick_timer()
	local timer = require 'timer.tick_timer'
	return timer.new()
end

--- 通过time驱动的timer
---@return ly.common.time_timer
function api.new_time_timer()
	local timer = require 'timer.time_timer'
	return timer.new()
end

return api