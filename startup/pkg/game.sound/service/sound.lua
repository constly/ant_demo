local ltask = require "ltask"
local aio = import_package "ant.io"
local GameSound = require "game.sound"

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

function S.play_music()
end 

function S.play_sound(path)
	S.preload(path)
	mgr:PlaySound(path, false)
	print("playsound", path)
end

function S.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end


ltask.fork(function()
	local _, last = ltask.now()
	mgr = GameSound.CreateSoundMgr()
	S.init()

	while not quit do 
		local _, now = ltask.now()
    	local delta = now - last
    	last = now
		S.update(delta * 0.001)
		ltask.sleep(0)
	end	
	ltask.wakeup(quit)
	mgr:Shutdown()
end)

return S;