__ANT_EDITOR__ = arg[1]  --- 如: F:/ant/ant_demo/startup

package.path = "/engine/?.lua"
require "bootstrap"

import_package "ant.window".start {
    window_size = "1400x800",
    enable_mouse = true,
    --feature = { "game.demo" },
	feature = { "mini.richman.go|gameplay" },
}
