local ltask = require "ltask"

local api = {}
local ServiceSound

function api.init()
	if not ServiceSound then
		ServiceSound = ltask.uniqueservice "game.sound|sound"
	end
	ltask.send(ServiceSound, "init")
end

function api.play_sound(path)
	ltask.send(ServiceSound, "preload", path)
	ltask.send(ServiceSound, "play_sound", path)
end

function api.play_music(path)
end

return api;