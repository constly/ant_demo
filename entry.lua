package.path = "/engine/?.lua"
require "bootstrap"

import_package "ant.window".start {
    window_size = "1400x800",
    enable_mouse = true,
    feature = {
        "game.demo",
        
        "ant.render",
        "ant.animation",
     --   "ant.camera|camera_controller",
        "ant.shadow_bounding|scene_bounding",
        "ant.imgui",
        "ant.pipeline",
        "ant.sky|sky",
    },
}
