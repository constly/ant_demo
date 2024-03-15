
---@class ly.game_editor
local api = {}

---@class ly.game_editor.create_params 编辑器创建参数
---@field roots string[] 文件根目录列表
---@field cb_file_saved function 通知文件保存
---@field module_name string 模块名
local create_params = {}

--- 创建游戏编辑器
---@param tbParams ly.game_editor.create_params
---@return ly.game_editor.editor
function api.create(tbParams)
	local editor = require 'editor.editor'
	return editor.create(tbParams)
end

return api