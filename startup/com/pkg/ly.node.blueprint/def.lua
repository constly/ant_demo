---@class ly.node.blueprint.def
local def = {}

-- 节点类型定义
def.type_blueprint = 1
def.type_simple = 2
def.type_tree = 3
def.type_comment = 4
def.type_houdini = 5

-- 脏标记类型
def.dirty_Navigation = 1
def.dirty_Position = 2
def.dirty_Size = 4
def.dirty_Selection = 8
def.dirty_AddNode = 16
def.dirty_RemoveNode = 32
def.dirty_User = 64

return def;