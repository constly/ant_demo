local ecs       = ...
local world     = ecs.world
local bgfx      = require "bgfx"
local math3d    = require "math3d"
local layoutmgr = require "layoutmgr"
local sampler   = require "sampler"
local platform  = require "bee.platform"
local OS        = platform.os

local utils		= require 'utils' ---@type test.bfgx.utils
local ROOT<const> = utils.Root

local is = ecs.system "init_system"


function is:init()
    
end

function is:update()
end