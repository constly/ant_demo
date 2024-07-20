---@class game_01.ui.main
local api = {}

---@type ly.common
api.common = import_package 'ly.common'

--- 创建ui
function api.create_ui(...)
	local ui_handler = require 'ui_handler'
	return ui_handler.new(...)
end

return api
