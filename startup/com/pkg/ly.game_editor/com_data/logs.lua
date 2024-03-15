--------------------------------------------------------
-- 日志相关
--------------------------------------------------------

---@class ly.game_editor.log_item
---@field type number 类型
---@field msg string 内容
local tb_log_data

---@param editor ly.game_editor.editor
local function create(editor)
	local api = {}		---@type ly.game_editor.logs
	api.list = {}		---@type ly.game_editor.log_item[]

	function api.add(type, msg)
		table.insert(api.list, {type = type, msg = msg})
	end

	return api
end
return {create = create}