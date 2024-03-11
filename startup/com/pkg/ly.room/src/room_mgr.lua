--------------------------------------------------------------
--- 房间总管理
--------------------------------------------------------------
local room_client = require 'src.room_client'
local room_server = require 'src.room_server'
local msg = require 'src.msg'
local players = require "src.players"

local api = {} 	---@class ly.room.room_mgr

api.players = players 				---@type ly.room.players
api.server = room_server			---@type ly.room.room_server
api.client = room_client			---@type ly.room.room_client
api.msg = msg 						---@type ly.room.msg

api.state = 1						---@type number 房间状态 1-匹配中; 2-战斗中; 3-战斗结束	


--- 清空所有数据
function api.close()
	room_server.close()
	room_client.close()
end

--- 初始化
function api.init()
	api.state = 1
end

--- 每帧更新
function api.tick()
	if room_server.is_open() then 
		room_server.tick()
	end
end 

-- 是否需要关闭房间
function api.is_valid()
	return room_client.is_open() or room_server.is_open()
end

return api
