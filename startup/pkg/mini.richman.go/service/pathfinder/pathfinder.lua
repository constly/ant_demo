------------------------------------------------------
--- pathfinder 寻路服务
------------------------------------------------------
SServer = ...
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
---@param map_path string 地图路径
function S.init(map_path)
end

--- 更新地图信息
---@param data table 数据类型: {{grid_id, grid_type}, {grid_id, grid_type}}
function S.update_map(data)
end

--- 请求寻路
---@param batch_id 请求批次id
---@param start_pos 起始点
---@param target_pos 目标点
function S.apply_find_path(batch_id, start_pos, target_pos)
	
end

--- 取消寻路
---@param batch_id 请求批次id
function S.cancel(batch_id)

end

function S.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end

ltask.fork(update)

return S;