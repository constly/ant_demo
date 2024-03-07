local dep 	= require 'dep'  	---@type mini.richman.go.dep
local api 	= {} 				---@class mini.richman.go.main 
api.tbParam = {}

--- 进入场景
function api.entry(tbParam)
	api.tbParam = tbParam
	dep.window.reboot({
		feature = {
			"mini.richman.go|gameplay",
		}
	})
end

-- 离开场景
function api.leave()
	if api.tbParam and api.tbParam.leaveCB then 
		api.tbParam.leaveCB()
	end
end

return api