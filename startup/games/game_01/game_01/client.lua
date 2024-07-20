local function new(ecs)
	---@class game_01.client
	---@field ecs any
	---@field world any
	local api = {}
	api.ecs 			= ecs
	api.world 			= ecs.world
	api.world.client 	= api
	api.RmlUi 			= ecs.require "ant.rmlui|rmlui_system"

	function api.init()
		local iRmlUi = api.RmlUi
		iRmlUi.open ("rmlui_01", "/pkg/game_01.res/ui/ui_entry.html")

		--- 注册退出游戏事件
		iRmlUi.onMessage("exit", function(msg)
			-- 发送消息, 只push, 不阻塞
			--iRmlUi.sendMessage("notify.exit", "hello send")

			os.exit(1, true)
		end)
	end

	function api.shutdown()
	end 
	
	function api.update(delta)
		--print("game_init", delta)
	end

	return api
end 

return {new = new}