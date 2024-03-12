---@class ly.room
local api = {}

---@return ly.room.room_list
function api.get_room_list()
	return require 'room_list'
end

return api