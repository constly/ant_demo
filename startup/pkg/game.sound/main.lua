local ltask = require "ltask"

local api = {}
local ServiceSound

function api.init()
	if not ServiceSound then
		ServiceSound = ltask.uniqueservice "game.sound|sound"
	end
end

function api.play_sound(path)
	api.init()
	-- 调用顺序似乎不能保证
	--ltask.send(ServiceSound, "preload", path)
	ltask.send(ServiceSound, "play_sound", path)
end

function api.play_music(path)
end

return api;