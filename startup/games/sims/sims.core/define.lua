---@class sims.define 数据定义
local api = {}

-- 区域划分相关
api.region_size_x = 20
api.region_size_y = 10
api.region_size_z = 20
api.region_limit = 1000000

api.player_view_distance_x = 60
api.player_view_distance_y = 40
api.player_view_distance_z = 60

api.INVALID_NUM = -1000000000

--- 世界坐标转换为区域id
function api.world_pos_to_region_id(pos_x, pos_y, pos_z)
	local x = math.floor(pos_x / api.region_size_x) + api.region_limit
	local y = math.floor(pos_y / api.region_size_y) + api.region_limit
	local z = math.floor(pos_z / api.region_size_z) + api.region_limit
	return (x << 42) | (y << 21) | z
end

--- 区域id转换为世界坐标
function api.region_id_to_world_pos(regionId)
	local x = ((regionId >> 42) - api.region_limit) * api.region_size_x
	local y = (((regionId >> 21) & ((1 << 21) - 1)) - api.region_limit) * api.region_size_y 
	local z = ((regionId & ((1 << 21) - 1)) - api.region_limit) * api.region_size_z
	return x, y, z
end

--- 世界坐标转换为格子坐标
function api.world_pos_to_grid_pos(pos_x, pos_y, pos_z)
	local x = math.floor(pos_x ) 
	local y = math.floor(pos_y * 2)
	local z = math.floor(pos_z)
	return x, y, z
end

--- 格子坐标转换为世界坐标
function api.grid_pos_to_world_pos(x, y, z)
	return x, y * 0.5, z
end

--- 区域偏移转换为区域中的索引
function api.region_offset_to_index(offset_x, offset_y, offset_z)
	return api.region_size_x * api.region_size_z * offset_y + offset_x * api.region_size_z + offset_z
end

--- 区域索引到区域偏移
function api.index_to_region_offset(index)
	local n1 = api.region_size_x * api.region_size_z
	local offset_y = math.floor(index / n1)
	local n2 = index % n1
	local offset_z = n2 % api.region_size_z
	local offset_x = math.floor(n2 / api.region_size_z)
	return offset_x, offset_y, offset_z
end


return api