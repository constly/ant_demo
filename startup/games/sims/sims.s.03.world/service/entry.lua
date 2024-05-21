------------------------------------------------------
--- world
--- world主service
------------------------------------------------------
local ltask = require "ltask"

---@type sims.s.world
local world = require 'world'.new()

local S = {}

---@param tbParam sims.server.start.params
function S.start(tbParam)
	world.start()
end

function S.shutdown()
	world.shutdown()
    ltask.quit()
end


return S;