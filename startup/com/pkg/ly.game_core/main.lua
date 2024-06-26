---@class ly.game_core
---@field mods ly.mods
local api = {}

---@return ly.mods
---@param tbParams ly.mods.param
function api.init_mod(tbParams)
	if not api.mods then 
		local mods_handler = require 'mod.mods'
		api.mods = mods_handler.new()
	end
	api.mods.remove_all()
	api.mods.init(tbParams)
	return api.mods
end


--- 创建ini_handler
---@return ly.game_editor.ini.handler
function api.create_ini_handler()
	local ini_handler = require 'data_handler.ini.ini_handler'
	return ini_handler.new()
end

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

--- 创建包管理相关接口
---@return ly.game_core.utils.package
function api.create_package_handler(project_root)
	local map_handler = require 'utils.package'
	return map_handler.new(project_root)
end

return api