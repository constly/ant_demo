local lm = require "luamake"
lm.AntDir = lm:path "3rd/ant"
lm:import(lm.AntDir .. "/make.lua")
lm:default {
    "bgfx-lib",
}