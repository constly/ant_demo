local lm = require "luamake"


-- 即使是空文件，也不能删除
lm:source_set "game.sound" {   
}

-- lua绑定相关代码只能放在 lua_source中，不然编译不过
lm:lua_source "game.sound" {
    includes = {
		lm.AntDir .. "/3rd/bee.lua",
    },
    sources = {
        "binding_sound.cpp",
    },
}
