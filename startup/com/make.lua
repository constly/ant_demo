local lm = require "luamake"
local fs = require "bee.filesystem"

local modules = {}
local libs = {"clibs", "pkg", "../pkg", "../games/sims"}
for i, name in ipairs(libs) do 
	for path in fs.pairs(lm.workdir .. "/" .. name) do
		if fs.exists(path / "make.lua") then
			local filename = path:filename():string()
			local makefile = ("%s/%s/make.lua"):format(name, filename)
			modules[#modules + 1] = filename
			lm:import (makefile)
			--print("import", filename, makefile)
		end
	end
end

lm:copy "bootstrap_lua" {
    inputs = "bootstrap.lua",
    outputs = "$bin/main.lua",
}


local LuaInclude = lm.AntDir .. "/3rd/bee.lua/3rd/lua"

if lm.os == "ios" then
    lm:lib "ant_demo" {
        deps = {
            "ant_runtime",
            "ant_links",
            modules
        },
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        sources = "../modules.c"
    }
    return
end

if lm.os == "android" then
    local jniDir
    local arch
    if lm.target then
        arch = lm.target:match "^[^-]*"
    elseif lm.arch then
        arch = lm.arch
    end
    if arch == "aarch64" then
        jniDir = "arm64-v8a"
    elseif arch == "x86_64" then
        jniDir = "x86_64"
    else
        error("unknown arch:" .. tostring(arch))
    end

    lm:dll "ant_demo" {
        basename = "libant_demo",
        crt = "static",
        bindir = "runtime/android/app/src/main/jniLibs/" .. jniDir,
        deps = {
            "ant_runtime",
            "ant_links",
            "bgfx-lib",
            modules
        },
        ldflags = "-Wl,--no-undefined",
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        sources = "../modules.c",
    }
    return
end

if lm.os == "macos" then
    lm:lib "ant_demo_rt_static" {
        deps = {
            "ant_runtime",
            "ant_links",
            "bootstrap_lua",
            modules
        },
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        sources = "../modules.c"
    }

    lm:exe "ant_demo" {			-- 编辑器版本
        deps = {
            "ant_editor",
            "bgfx-lib",
            "ant_links",
            "bootstrap_lua",
            modules
        },
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        msvc = {
            defines = "LUA_BUILD_AS_DLL",
        },
        sources = "../modules.c"
    }
    lm:exe "ant_demo_rt" {		-- 运行时版本
        deps = {
            "ant_runtime",
            "bgfx-lib",
            "ant_links",
            "bootstrap_lua",
            modules
        },
        includes = {
            LuaInclude,
            lm.AntDir .. "/runtime/common",
        },
        frameworks = {
            "Carbon",
            "Cocoa",
            "IOKit",
            "IOSurface",
            "Metal",
            "QuartzCore",
        },
        sources = "../modules.c"
    }
    return
end

lm:exe "ant_demo" {	
    deps = {
        "ant_runtime",
        "bgfx-lib",
        "ant_links",
		"bootstrap_lua",
        modules
    },
    includes = {
        LuaInclude,
        lm.AntDir .. "/runtime/common",
    },
    msvc = {
        defines = "LUA_BUILD_AS_DLL",
    },
    sources = {
        "../modules.c",
        "../../runtime/win32/ant_demo.rc"
    }
}
