local window = import_package "ant.window"
local api 	= {} 				---@class ly.room.match.main
api.tbParam = {} 				---@type ly.room.match.param

--- 进入场景
---@param tbParam ly.room.match.param
function api.entry(tbParam)
	api.tbParam = tbParam
	window.reboot({
		feature = { "ly.room.match" }
	})
end

-- 离开场景
function api.leave()
	if api.tbParam and api.tbParam.leaveCB then 
		api.tbParam.leaveCB()
	end
end

return api