--------------------------------------------------------------
--- 局域网建房间
--------------------------------------------------------------
local window = import_package "ant.window"
local api 	= {} 				---@class ly.room.main
api.tbParam = {} 				---@type ly.room.param

api.mgr 	= require 'src.room_mgr'	---@type ly.room.room_mgr


--- 进入场景
---@param tbParam ly.room.param
function api.entry(tbParam)
	api.tbParam = tbParam
	window.reboot({
		feature = { "ly.room" }
	})
end

-- 离开场景
function api.leave()
	if api.tbParam and api.tbParam.leaveCB then 
		api.tbParam.leaveCB()
	end
end

return api