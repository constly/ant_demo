local ltask = require "ltask"

---@class ly.sound.main
local api = {}
local service

function api.init()
	if not service then
		service = ltask.uniqueservice "ly.sound|sound"
	end
end

function api.exit()
	ltask.send(service, "shutdown")
end

function api.play_sound(path)
	api.init()
	-- 调用顺序似乎不能保证
	--ltask.send(ServiceSound, "preload", path)
	ltask.send(service, "play_sound", path)
end

function api.play_music(path)
	api.init()
	ltask.send(service, "play_music", path)
end


function api.set_global_volume(volume)
	api.init()
	ltask.send(service, "set_global_volume", volume)
end

function api.set_music_volume(volume)
	ltask.send(service, "set_music_volume", volume)
end

function api.set_sound_volume(volume)
	ltask.send(service, "set_sound_volume", volume)
end

return api;