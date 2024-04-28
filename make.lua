local lm = require "luamake"

lm:required_version "1.6"

lm.compile_commands = "build"

lm.AntDir = lm:path "../ant"

lm:conf {
    mode = "debug",
    visibility = "default",
    c = "c17",
    cxx = "c++20",
    macos = {
        sys = "macos13.3",
    },
    ios = {
        arch = "arm64",
        sys = "ios16.3",
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
        if lm.cc == "clang-cl" then
            return "clang-cl"
        end
        return "msvc"
    end
    if lm.os == "android" then
        return "android-"..lm.arch
    end
    return lm.os
end)()
lm.builddir = ("build/%s/%s"):format(plat, lm.mode)
lm.bindir = ("bin/%s/%s"):format(plat, lm.mode)

if lm.sanitize then
    lm.builddir = ("build/%s/sanitize"):format(plat)
    lm.bindir = ("bin/%s/sanitize"):format(plat)
    lm.mode = "debug"
    lm:conf {
        flags = "-fsanitize=address",
        gcc = {
            ldflags = "-fsanitize=address"
        },
        clang = {
            ldflags = "-fsanitize=address"
        }
    }
    lm:msvc_copydll "copy_asan_v2" {
        type = "asan",
        outputs = lm.bindir,
    }
end

lm:import(lm.AntDir .. "/make.lua")
lm:import "startup/com/make.lua"

if lm.os == "windows" then
    lm:copy "copy_dll" {
        inputs = {
            lm.AntDir .. "/3rd/fmod/windows/core/lib/x64/fmod.dll",
            lm.AntDir .. "/3rd/fmod/windows/studio/lib/x64/fmodstudio.dll",
            lm.AntDir .. "/3rd/vulkan/x64/vulkan-1.dll",
        },
        outputs = {
            "$bin/fmod.dll",
            "$bin/fmodstudio.dll",
            "$bin/vulkan-1.dll",
        },
    }
    lm:default {
        "ant",
        "copy_dll",
        "ant_demo",
        lm.sanitize and "copy_asan_v2",
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

lm:default {
    "ant",
    "ant_demo",
}
