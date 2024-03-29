---------------------------------------------------------------------------
--- 蓝图系统
---------------------------------------------------------------------------

---@class ly.node.blueprint.main
local api = {}

api.blueprint_builder 		= require "common.blueprint_builder"
api.def 					= require 'def'


-- 创建蓝图编辑器
---@param args node_editor_create_args
---@return blueprint_editor
function api.create_editor(args)
	local editor = require 'editor.editor'
	local base = editor.create(args)
	return setmetatable({}, { __index = base});
end 


return api