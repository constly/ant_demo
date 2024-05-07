local ltask = require "ltask"
local aio = import_package "ant.io"
local GameSound = require "ly.sound.impl"

local mgr 
local quit
local S = {}

function S.init()
	mgr:Init()
	mgr:SetGlobalVolume(1)
end 

function S.update(delta)
	mgr:Update(delta)
end

function S.preload(path)
	if mgr:IsPreload(path) then 
		return 
	end
	local data = aio.readall(path)
	if data then 
		mgr:Preload(path, data)
	end
	print("preload", path)
end

function S.set_global_volume(volume)
	mgr:SetGlobalVolume(volume)
end

function S.set_music_volume(volume)
	mgr:SetMusicVolume(volume)
end

function S.set_sound_volume(volume)
	mgr:SetSoundVolume(volume)
end

function S.play_music(path)
	S.preload(path)
	mgr:PlayMusic(path, 0)
	print("play_music", path)
end 

function S.play_sound(path)
	S.preload(path)
	mgr:PlaySound(path, false)
	print("play_sound", path)
end

function S.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

ltask.fork(function()
	local last = os.clock()
	mgr = GameSound.CreateSoundMgr()
	S.init()

	while not quit do 
		local now = os.clock()
    	local delta = now - last
    	last = now
		S.update(delta)
		ltask.sleep(0)
	end	
	ltask.wakeup(quit)
	mgr:Shutdown()
end)

return S;