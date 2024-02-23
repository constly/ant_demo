local lm = require "luamake"
local fs = require "bee.filesystem"

local modules = {}
local function checkAddModule(name, makefile)
	print("checkAddModule", name, makefile)
	modules[#modules + 1] = name
	lm:import (makefile)
end

for path in fs.pairs(fs.path(lm.workdir) / "clibs") do
    if fs.exists(path / "make.lua") then
        local name = path:filename():string()
        local makefile = ("clibs/%s/make.lua"):format(name)
		checkAddModule(name, makefile)
    end
end

for path in fs.pairs(fs.path(lm.workdir) / "pkg") do
    if fs.exists(path / "make.lua") then
        local name = path:filename():string()
        local makefile = ("pkg/%s/make.lua"):format(name)
		checkAddModule(name, makefile)
    end
end

for path in fs.pairs(fs.path(lm.workdir) / "../pkg") do
    if fs.exists(path / "make.lua") then
        local name = path:filename():string()
        local makefile = ("../pkg/%s/make.lua"):format(name)
		checkAddModule(name, makefile)
    end
end

lm:copy "bootstrap_lua" {
    input = "bootstrap.lua",
    output = "../../" .. lm.bindir .. "/main.lua",
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

    lm:exe "ant_demo" {
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
    lm:exe "ant_demo_rt" {
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
    sources = {
        "../modules.c",
        "../../runtime/win32/ant_demo.rc"
    }
}

lm:exe "ant_demo_rt" {
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
    sources = {
        "../modules.c",
        "../../runtime/win32/ant_demo.rc"
    }
}
