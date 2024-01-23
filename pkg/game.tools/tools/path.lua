local fs = require "bee.filesystem"
local vfs = require "vfs"
local api = {}

-- 临时数据存储目录 (磁盘全路径)
-- 如: D:/git/ant/ant_demo/.app/temp
api.disk_temp_data_root = (fs.path(vfs.repopath()) / ".app/temp/"):string()
fs.create_directories(api.disk_temp_data_root)

-- 项目目录 (磁盘全路径)
-- 如: D:/git/ant/ant_demo/
api.disk_project_root = vfs.repopath()

-- 资源根目录
-- 如: D:/git/ant/ant_demo/pkg/game.res/
api.disk_res_root = api.disk_project_root .. 'pkg/game.res/'

-- vfs路径
api.vfs_res_root = "/pkg/game.res/"


return api