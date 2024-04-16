---@class ly.game_core
local api = {}

--- 创建goap_handler
---@return ly.game_core.goap.handler
function api.create_goap_handler(vfs_path)
	local goap_handler = require 'data_handler.goap.goap_handler'
	return goap_handler.new(vfs_path)
end

--- 创建tag_handler 
---@return ly.game_core.tag.handler
function api.create_tag_handler()
	local tag_handler = require 'data_handler.tag.tag_handler'
	return tag_handler.new()
end

--- 创建attr_handler 
---@return ly.game_core.attr.handler
function api.create_attr_handler()
	local attr_handler = require 'data_handler.attr.attr_handler'
	return attr_handler.new()
end

--- 创建map_handler 
---@return chess_data_handler
function api.create_map_handler()
	local map_handler = require 'data_handler.map.map_handler'
	return map_handler.new()
end


return api