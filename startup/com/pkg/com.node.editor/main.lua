local blueprint = require "blueprint.main"
local cartoon = require "cartoon.main"

local api = {}

---@class node_editor_create_args 节点创建参数说明
local args = 
{
	-- 图的类型
	-- blueprint : 	蓝图编辑器，挂载在游戏实体上，用于 通用逻辑处理，npc动画，关卡流程管理 等
	-- cartoon: 	剧情编辑器
	-- skill: 		技能编辑器
	-- ai:  		npc行为编辑器
	-- grid_map: 	格子地图
	type = "";		

	-- 子图数量
	subgraph = 1,

	-- 节点声明列表
	---@type node_builder_declare
	node_declares = {}
}

-- 创建节点编辑器
---@param args node_editor_create_args
function api.create(args)
	local base = {}
	if args.type == "blueprint" then 
		base = blueprint.create(args)
	else 
		error("尚不支持的图: " .. args.type)
	end
	local editor = {}
	setmetatable(editor, { __index = base});
	return editor
end 


return api;