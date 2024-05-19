------------------------------------------------------
--- data_center 
--- 服务器数据中心，其他服务都来这里存取数据
--- 本服务还负责处理存档/读档
------------------------------------------------------
SServer = ...
local ltask = require "ltask"
local quit

---@type sims.s.data_center
local data_center = require 'data_center'.new()

local S = {}

function S.start(tbParam)
	data_center.start()
end

function S.shutdown()
	data_center.shutdown()
	quit = {}
    ltask.wait(quit)
    ltask.quit()
end


return S;