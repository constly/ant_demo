------------------------------------------------------
--- gaop ai 服务规划入口
------------------------------------------------------
SServer = ...
---@type ly.game_core
local game_core = import_package 'ly.game_core'

---@type ly.common.main
local common = import_package 'ly.common'

local ltask = require "ltask"
local quit

local function update()
	while not quit do 
		ltask.sleep(5)
	end
	ltask.wakeup(quit)
end

local S = {}

--- 初始化
---@param files string[] goap文件列表
function S.init(files)
	for i, file in ipairs(files) do 
		local goap_handler = game_core.create_goap_handler()
		common.lib.dump(goap_handler)
	end
end

--- 请求指定ai行为计划
---@param entity table 实体类型
---@param type string entity类型
---@param target table 计划目标
function S.apply(entity, type, target)
	print("apply", type, entity, target)
end

function S.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

ltask.fork(update)

return S;