local arg = ...

import_package "ant.window".start {
    window_size = "1200x700",
    enable_mouse = true,
    feature = { "game_01" },
	project_root = arg[1], 		--- 项目根目录，如: F:/ant/ant_demo/startup
}
