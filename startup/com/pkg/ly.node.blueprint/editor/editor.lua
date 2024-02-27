---------------------------------------------------------------------------
-- 编辑器由多个子图组成
-- 图内可以定义局部变量 和 局部函数
---------------------------------------------------------------------------
local dep = require "dep" ---@type ly.node.blueprint.dep
local graph_draw = require 'editor.graph_draw'
local data_hander = require 'common.data_handler'

---@param args node_editor_create_args
local create = function(args)
	---@class blueprint_graph_main
	local editor = {}									
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = data_hander.create()			---@type blueprint_data_handler
	local graph_draw = graph_draw.create(editor)		---@type blueprint_graph_draw

	editor.args = args									---@type node_editor_create_args
	editor.blueprint_builder = args.blueprint_builder	---@type blueprint_builder
	editor.stack = stack
	editor.data_hander = data_hander
	
	function editor.on_init()
		stack.set_data_handler(data_hander)	
		data_hander.init(args)
		stack.snapshoot()
		graph_draw.on_init()
	end

	function editor.on_begin()

	end 

	function editor.on_destroy()
		graph_draw.on_destroy()
	end 

	function editor.on_render(deltatime)
		local data = data_hander.get_cur_graph()
		if data then
			graph_draw.on_render(data, deltatime)
		end
	end

	editor.on_init()
	return editor
end 


return {create = create}