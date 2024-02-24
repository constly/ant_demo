---------------------------------------------------------------------------
-- 数据处理
---------------------------------------------------------------------------

-- 子图数据
local create_subgraph_data = function()
	---@class subgraph_data
	local data = {}

	return data;
end

-- 图数据
local create_graph_data = function()
	---@class graph_data 
	local data = {}

	---@type subgraph_data[] 子图数据列表
	data.subgraphs = {}

	---@type number 当前激活的子图
	data.index = 1;

	return data
end

-- 图数据处理器
local create = function()
	---@class blueprint_data_handler
	local handler = {}

	---@type graph_data
	handler.data = {}
	
	---@param args node_editor_create_args  
	function handler.init(args)
		local data = create_graph_data()
		for i = 1, args.subgraph do 
			local sub = create_subgraph_data()
			table.insert(data.subgraphs, sub)
		end
		handler.data = data
	end 

	return handler
end 

return {create = create}