local ltask = require "ltask"

---@class sound_api
local api = {}
local ServiceSound

function api.init()
	if not ServiceSound then
		ServiceSound = ltask.uniqueservice "com.sound|sound"
	end
end

function api.exit()
	ltask.send(ServiceSound, "shutdown")
end

function api.play_sound(path)
	api.init()
	-- 调用顺序似乎不能保证
	--ltask.send(ServiceSound, "preload", path)
	ltask.send(ServiceSound, "play_sound", path)
end

function api.play_music(path)
	api.init()
	ltask.send(ServiceSound, "play_music", path)
end


function api.set_global_volume(volume)
	api.init()
	ltask.send(ServiceSound, "set_global_volume", volume)
end

function api.set_music_volume(volume)
	ltask.send(ServiceSound, "set_music_volume", volume)
end

function api.set_sound_volume(volume)
	ltask.send(ServiceSound, "set_sound_volume", volume)
end

return api;