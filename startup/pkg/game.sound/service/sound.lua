local ltask = require "ltask"
local aio = import_package "ant.io"
local GameSound = require "game.sound"

local mgr = GameSound.CreateSoundMgr()
local quit
local S = {}

function S.init()
	print("init sound")
end 

function S.update(delta)
	--mgr:Update(delta)
end

function S.preload(path)
	local data = aio.readall(path)
	if data then 
		mgr:Preload(path, data)
	end
end

function S.play_music()
end 

function S.play_sound(path)
	mgr:PlaySound(path, false)
end

function S.shutdown()
	quit = {}
    ltask.wait(quit)
    mgr:Shutdown()
    ltask.quit()
end


ltask.fork(function()
	local _, last = ltask.now()
	while not quit do 
		local _, now = ltask.now()
    	local delta = now - last
		--print("sound update", now, last, delta)
    	last = now
		S.update(delta * 0.001)
		ltask.sleep(50)
	end	
	ltask.wakeup(quit)
end)

return S;