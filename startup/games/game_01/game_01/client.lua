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
		local ui = iRmlUi.open ("rmlui_01", "/pkg/game_01.ui/ui/ui_entry/ui_entry.html")

		-- 注册事件
		iRmlUi.onMessage("click", function (msg)
			print(msg)
			iRmlUi.sendMessage("rmlui_01.test", msg)

			if msg == "exit" then
				iRmlUi.onMessage("click", nil)
				ui.close()
			end
		end)
		
		-- 发送消息, 只push, 不阻塞
		iRmlUi.sendMessage("rmlui_01.test", "hello send")
	end

	function api.shutdown()
	end 
	
	function api.update(delta)
		--print("game_init", delta)
	end

	return api
end 

return {new = new}