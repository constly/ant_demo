local lm = require "luamake"

-- 非lua相关的代码放这里
lm:source_set "ly.net" {
    
}

-- lua绑定相关代码只能放在 lua_source中，不然编译不过
lm:lua_source "ly.net" {
    includes = {
		lm.AntDir .. "/3rd/bee.lua",
    },
    sources = {
        "lua_broadcast.cpp",
    },
}
