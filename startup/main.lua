local arg = ...

import_package "ant.window".start {
    window_size = "1400x800",
    enable_mouse = true,
    --feature = { "game.demo" },
	feature = { "sims1|gameplay" },
	project_root = arg[1], 		--- 项目根目录，如: F:/ant/ant_demo/startup
}
