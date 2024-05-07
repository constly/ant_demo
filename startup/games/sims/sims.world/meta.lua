---@class sims.world.c_world 
---@field InValidNum number 无效数值
local c_world = {}
function c_world:Update() end
function c_world:Destroy() end
function c_world:SetRegionSize(size_x, size_y, size_z) end
function c_world:SetMaxAgentSize(size) end

---@param checkRange number 默认200
function c_world:GetGroundHeight(pos_x, pos_y, pos_z, checkRange) end

---@param gridType sims.world.GridType
function c_world:SetGridData(start_x, start_y, start_z, size_x, size_y, size_z, gridType) end
function c_world:FindPath() end


---@class sims.world.WalkType 寻路类型定义
---@field Ground number
---@field Sky number
---@field Water number
---@field Wall number


---@class sims.world.GridType 格子类型定义
---@field None enum
---@field Under_Water enum
---@field Under_Object enum
---@field Under_Ground enum
---@field Under_StandableObject enum
---@field Ground enum
---@field Wall enum
---@field Water enum
---@field Ceiling enum