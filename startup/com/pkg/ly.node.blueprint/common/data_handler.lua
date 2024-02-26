---------------------------------------------------------------------------
-- 蓝图数据处理
---------------------------------------------------------------------------
local dep = require 'dep' ---@type ly.node.blueprint.dep
-- 图数据
local create_graph_data = function()
	---@class blueprint_graph_data
	local data = {}

	---@type blueprint_node_data[]
	data.nodes = {}

	return data;
end

-- 蓝图总数据
local create_blueprint_data = function()
	---@class blueprint_data 
	local data = {}

	---@type blueprint_graph_data[] 子图数据列表
	data.graphs = {}

	---@type number 当前激活的子图
	data.index = 1;

	---@type number 下个id
	data.next_id = 0

	return data
end

-- 图数据处理器
local create = function()
	---@class blueprint_data_handler
	local handler = {}

	---@type blueprint_data
	handler.data = {}

	function handler.next_id()
		local data = handler.data 
		data.next_id = data.next_id + 1; 
		return data.next_id
	end

	--- 得到当前编辑的子图
	function handler.get_cur_graph()
		local data = handler.data
		return data.graphs[data.index]
	end 

	---@param args node_editor_create_args  
	function handler.init(args)
		local data = create_blueprint_data()
		args.graph_count = args.graph_count or 1
		for i = 1, args.graph_count do 
			local sub = create_graph_data()
			table.insert(data.graphs, sub)
		end
		handler.data = data
	end 

	--- 创建节点
	---@param node_tpl blueprint_node_tpl_data
	function handler.create_node(pos_x, pos_y, node_tpl)
		local g = handler.get_cur_graph()
		if not g then return end 

		---@type blueprint_node_data
		local node = {}
		node.pos_x = pos_x
		node.pos_y = pos_y
		node.tplId = node_tpl.name
		node.id = handler.next_id()
		handler.fix_node(node, node_tpl)

		table.insert(g.nodes, node)
	end

	--- 修复节点 (当节点定义变化，运行时数据也需要重新适配)
	---@param node blueprint_node_data
	---@param node_tpl blueprint_node_tpl_data
	function handler.fix_node(node, node_tpl)
		local tbs = {}
		for i, v in ipairs(node_tpl.pins) do 
			local tb = tbs[v.type] or {}
			tbs[v.type] = tb
			table.insert(tb, v)
		end

		---@param tb_tpl blueprint_node_pin_tpl_data[]
		---@param tb blueprint_node_pin_data[]
		local process = function(tb, tb_tpl)
			---@type blueprint_node_pin_data[]
			local ret = {}
			if not tb_tpl then return ret end

			tb = tb or {}
			for _, tpl in ipairs(tb_tpl) do 
				ret[#ret + 1] = {key = tpl.name}
			end

			for i, data in ipairs(ret) do 
				local find = false
				for _, old in ipairs(tb) do 
					if old.key == data.key then 
						find = true;
						data.id = old.id 
						data.value = old.value
						break
					end
				end
				if not find then 
					data.id = handler.next_id()
				end
			end
			return ret
		end
		node.input_flows = process(node.input_flows, tbs["input_flow"])
		node.input_vars = process(node.input_vars, tbs["input_var"])
		node.delegates = process(node.delegates, tbs["delegate"])
		node.output_flows = process(node.output_flows, tbs["output_flow"])
		node.output_vars = process(node.output_vars, tbs["output_var"])
		node.tpl = node_tpl
	end

	return handler
end 

return {create = create}