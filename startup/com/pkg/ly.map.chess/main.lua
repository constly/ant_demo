---@class ly.map.chess.main
local api = {}

---@param args chess_editor_create_args
---@return chess_editor
function api.create(args)
	local editor = require 'editor.editor'
	local base = editor.create(args)
	return setmetatable({}, { __index = base});
end

return api;