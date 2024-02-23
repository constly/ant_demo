local lm = require "luamake"

lm:required_version "1.6"

lm.compile_commands = "build"

lm.AntDir = lm:path "../ant"

lm:conf {
    mode = "debug",
    --optimize = "speed"
    visibility = "default",
    c = "c17",
    cxx = "c++20",
    macos = {
        sys = "macos13.0",
    },
    ios = {
        arch = "arm64",
        sys = "ios16.0",
        flags = {
            "-fembed-bitcode",
            "-fobjc-arc"
        }
    },
    android  = {
        flags = "-fPIC",
        arch = "aarch64",
        vendor = "linux",
        sys = "android33",
    }
}

local plat = (function ()
    if lm.os == "windows" then
        if lm.compiler == "gcc" then
            return "mingw"
        end
        return "msvc"
    end
    if lm.os == "android" then
        return lm.os.."-"..lm.arch
    end
    return lm.os
end)()
lm.builddir = ("build/%s/%s"):format(plat, lm.mode)
lm.bindir = ("bin/%s/%s"):format(plat, lm.mode)

lm:import(lm.AntDir .. "/make.lua")
lm:import "startup/com/make.lua"

if lm.os == "windows" then
    lm:copy "copy_dll" {
        input = {
            lm.AntDir .. "/3rd/fmod/windows/core/lib/x64/fmod.dll",
            lm.AntDir .. "/3rd/fmod/windows/studio/lib/x64/fmodstudio.dll",
            lm.AntDir .. "/3rd/vulkan/x64/vulkan-1.dll",
        },
        output = {
            lm.bindir .. "/fmod.dll",
            lm.bindir .. "/fmodstudio.dll",
            lm.bindir .. "/vulkan-1.dll",
        },
    }
    lm:default {
        "copy_dll",
        "ant_demo_rt",
        "ant_demo",
    }
    return
end

if lm.os == "ios" then
    lm:default {
        "bgfx-lib",
        "ant_demo",
    }
    return
end

if lm.os == "android" then
    lm:default {
        "ant_demo",
    }
    return
end

lm:default {
    "ant_demo_rt_static",
    "ant_demo_rt",
    "ant_demo",
}
