---@class game_01.ui.main
local api = {}

function api.create_ui(...)
	local ui_handler = require 'ui_handler'
	return ui_handler.new(...)
end

return api
