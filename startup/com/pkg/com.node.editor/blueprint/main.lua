---------------------------------------------------------------------------
-- 图
-- 一个图由多个子图组成
-- 图内可以定义局部变量 和 局部函数
-- 所有子图共享图的局部变量和局部函数
---------------------------------------------------------------------------
local graph_draw = require 'blueprint.graph_draw'
local stack = require 'utils.data_stack'
local data_hander = require 'blueprint.data_handler'

---@param args node_editor_create_args
local create = function(args)
	---@class blueprint_graph_main
	local graph = {}									
	local stack = stack.create()						---@type node_editor_data_stack
	local data_hander = data_hander.create()			---@type blueprint_data_handler
	local graph_draw = graph_draw.create(graph)				---@type blueprint_graph_draw

	function graph.on_init()
		stack.set_data_handler(data_hander)	
		data_hander.init(args)
		stack.snapshoot()
		graph_draw.on_init()
	end

	function graph.on_begin()

	end 

	function graph.on_destroy()
		graph_draw.on_destroy()
	end 

	function graph.on_render(deltatime)
		graph_draw.on_render(deltatime)
	end

	graph.stack = stack
	graph.data_hander = data_hander
	graph.on_init()
	return graph
end 


return {create = create}