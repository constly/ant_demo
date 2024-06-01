---@class ly.world.c_world 
---@field InValidNum number 无效数值
local c_world = {}
function c_world:Update() end
function c_world:Destroy() end
function c_world:SetRegionSize(size_x, size_y, size_z) end
function c_world:SetMaxAgentSize(size) end
function c_world:Reset() end

---@param checkRange number 默认200
function c_world:GetGroundHeight(pos_x, pos_y, pos_z, checkRange) end

---@param gridType ly.world.GridType
function c_world:SetGridData(start_x, start_y, start_z, size_x, size_y, size_z, gridType) end

---@param bodySize number
---@param walkType ly.world.WalkType
function c_world:FindPath(start_x, start_y, start_z, dest_x, dest_y, dest_z, bodySize, walkType) end


---@class ly.world.WalkType 寻路类型定义
---@field Ground number
---@field Sky number
---@field Water number
---@field Wall number


---@class ly.world.GridType 格子类型定义
---@field None enum
---@field Under_Water enum 水中
---@field Under_Ground enum 地形中
---@field Under_Object enum 不可以站立物件内部 （比如场景的某个格子是个花瓶）	
---@field Under_StandableObject enum 可站立物件内部（比如场景地块，或者场景中有个可以站立的箱子）
---@field Ground enum 地表面
---@field Wall enum 墙表面
---@field Water enum 水表面
---@field Ceiling enum 天花板