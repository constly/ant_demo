package.path = "/engine/?.lua"
require "bootstrap"

import_package "ant.window".start {
    window_size = "1400x800",
    enable_mouse = true,
    feature = { "game.demo" },
}
