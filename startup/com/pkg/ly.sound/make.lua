local lm = require "luamake"


-- 即使是空文件，也不能删除
lm:source_set "ly.sound" {   
}

-- lua绑定相关代码只能放在 lua_source中，不然编译不过
lm:lua_source "ly.sound" {
    includes = {
		lm.AntDir .. "/3rd/bee.lua",
		lm.AntDir .. "/clibs/luabind",
    },
    sources = {
        "src/binding_sound.cpp",
    },
}
