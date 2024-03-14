local lm = require "luamake"


-- 即使是空文件，也不能删除
lm:source_set "ly.dotween" {   
}

-- lua绑定相关代码只能放在 lua_source中，不然编译不过
lm:lua_source "ly.dotween" {
    includes = {
		lm.AntDir .. "/3rd/bee.lua",
		lm.AntDir .. "/clibs/luabind",
    },
    sources = {
        "src/lua_tween.cpp",
    },
}
