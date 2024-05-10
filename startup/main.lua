local arg = ...

import_package "ant.window".start {
    window_size = "900x600",
    enable_mouse = true,
    feature = { "entry" },
	project_root = arg[1], 		--- 项目根目录，如: F:/ant/ant_demo/startup
}
