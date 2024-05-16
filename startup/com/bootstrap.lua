if arg[1] == "-s" then
    arg[0] = "../ant/tools/fileserver/main.lua"
elseif arg[1] == "-p" then
    arg[0] = "../ant/tools/filepack/main.lua"
elseif arg[1] == "-d" then
    arg[0] = "../ant/tools/editor/main.lua"
elseif arg[1] == nil or arg[1] == "" then
    arg[0] = "startup/main.lua"
else
    arg[0] = table.remove(arg, 1)
end

local fs = require "bee.filesystem"
local sys = require "bee.sys"
local ProjectDir = sys.exe_path()
    :parent_path()
    :parent_path()
    :parent_path()
    :parent_path()
fs.current_path(ProjectDir / ".." / "ant")
arg[0] = (ProjectDir / arg[0]):string()
arg[1] = tostring(ProjectDir) .. "/startup"

dofile "/engine/console/bootstrap.lua"
