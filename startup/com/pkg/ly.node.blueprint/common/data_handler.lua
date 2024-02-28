---------------------------------------------------------------------------
-- 蓝图数据处理
---------------------------------------------------------------------------
local dep = require 'dep' ---@type ly.node.blueprint.dep
local def = require 'def' ---@type ly.node.blueprint.def

-- 图数据
local create_graph_data = function()
	---@class blueprint_graph_data
	---@field nodes blueprint_node_data[]
	---@field links blueprint_link_data[]
	local data = {
		nodes = {},
		links = {},
	}
	return data;
end

-- 蓝图总数据
local create_blueprint_data = function()
	---@class blueprint_data 
	---@field graphs blueprint_graph_data[] 子图数据列表
	---@field index number 当前激活的子图
	---@field number 下个id
	---@field version 数据版本号
	local data = {
		graphs = {},
		index = 1,
		next_id = 0,
		version = 1,	
	}
	return data
end

-- 图数据处理器
local create = function()
	---@class blueprint_data_handler
	---@field data blueprint_data 蓝图数据
	---@field stack_version number 堆栈版本号,当堆栈版本号发生变化时，需要刷新编辑器
	local handler = {
		data = {},
		stack_version = 0,
	}

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

	---@param graph_data blueprint_graph_data
	---@return blueprint_node_data
	function handler.find_node(graph_data, nodeId)
		for i, node in ipairs(graph_data.nodes) do 
			if node.id == nodeId then 
				return node
			end
		end
	end

	---@param graph_data blueprint_graph_data
	---@return blueprint_link_data
	function handler.find_link(graph_data, linkId)
		for i, link in ipairs(graph_data.links) do 
			if link.id == linkId then 
				return link
			end
		end
	end

	---@param graph_data blueprint_graph_data
	---@param pinId number
	---@return blueprint_node_pin_data
	function handler.find_pin(graph_data, pinId)
		if not pinId or pinId <= 0 then return end 
		for i, node in ipairs(graph_data.nodes) do 
			for _, pin in ipairs(node.inputs) do 
				if pin.id == pinId then 
					return pin, node
				end
			end
			for _, pin in ipairs(node.outputs) do 
				if pin.id == pinId then 
					return pin, node
				end
			end
			for _, pin in ipairs(node.delegates) do 
				if pin.id == pinId then 
					return pin, node
				end
			end
		end
	end

	---@param graph_data blueprint_graph_data
	---@return blueprint_link_data
	function handler.find_link_by_pin(graph_data, pinId)
		for i, link in ipairs(graph_data.links) do 
			if link.startPin == pinId or link.endPin == pinId then 
				return link
			end
		end
	end

	---@param graph_data blueprint_graph_data
	---@return boolean
	function handler.is_pin_linked(graph_data, pinId)
		return handler.find_link_by_pin(graph_data, pinId) ~= nil
	end

	---@param graph_data blueprint_graph_data
	---@param pinA blueprint_node_pin_data
	---@param pinB blueprint_node_pin_data
	function handler.can_create_link(graph_data, pinA, pinB, node1, node2)
		if pinA == pinB or not pinA or not pinB then return false end 
		if pinA.kind == pinB.kind or pinA.type ~= pinB.type then return false end 
		if node1 == node2 then return false end;
		return true
	end

	---@param graph_data blueprint_graph_data
	---@return boolean
	function handler.remove_node(graph_data, nodeId)
		print("删除节点时，对应的连线也要一起删除掉")
		for i, v in ipairs(graph_data.nodes) do 
			if v.id == nodeId then 
				table.remove(graph_data.nodes, i);
				return true;
			end
		end
		return  false
	end

	---@param graph_data blueprint_graph_data
	---@return boolean
	function handler.remove_link(graph_data, linkId)
		for i, v in ipairs(graph_data.links) do 
			if v.id == linkId then 
				table.remove(graph_data.links, i);
				return true;
			end
		end
		return false
	end

	--- 创建节点
	---@param node_tpl blueprint_node_tpl_data
	---@return nil
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

		--dep.common.lib.dump(node)

		table.insert(g.nodes, node)
	end

	--- 修复节点 (当节点定义变化，运行时数据需要重新适配)
	---@param node blueprint_node_data
	---@param node_tpl blueprint_node_tpl_data
	function handler.fix_node(node, node_tpl)
		local process = function(tbold, type1, type2, kind)
			---@type blueprint_node_pin_data[]
			tbold = tbold or {}
			---@type blueprint_node_pin_data[]
			local pins = {}
			for i, v in ipairs(node_tpl.pins) do 
				local tpl = v ---@type blueprint_node_pin_tpl_data
				if tpl.type == type1 or tpl.type == type2 then 
					local pin = {key = tpl.name or ""} ---@type blueprint_node_pin_data
					pin.type = handler.get_pin_type(tpl);
					pin.kind = kind
					pins[#pins + 1] = pin
				end
			end

			for i, pin in ipairs(pins) do 
				for _, old in ipairs(tbold) do 
					if old.type == pin.type and old.key == pin.key then 
						pin.id = old.id;
						pin.value = old.value
						break
					end
				end
				if not pin.id then 
					pin.id = handler.next_id();
				end
			end
			return pins;
		end

		local PinKind = dep.ed.PinKind
		node.inputs = process(node.inputs, "input_flow", "input_var", PinKind.Input)
		node.delegates = process(node.delegates, "delegate", "", PinKind.Output)
		node.outputs = process(node.outputs, "output_flow", "output_var", PinKind.Output)
	end

	-- 得到pin类型
	---@param pinTpl blueprint_node_pin_tpl_data
	function handler.get_pin_type(pinTpl)
		local PinType = dep.ed.PinType
		local szType = pinTpl.type
		if szType == "input_flow" or szType == "output_flow" then 
			return PinType.Flow
		elseif szType == "delegate" then 
			return PinType.Delegate;
		elseif pinTpl.data_type == "int" then return PinType.Int 
		elseif pinTpl.data_type == "float" then return PinType.Float 
		elseif pinTpl.data_type == "string" then return PinType.String
		elseif pinTpl.data_type == "bool" then return PinType.Bool
		elseif pinTpl.data_type == "object" then return PinType.Object
		elseif pinTpl.data_type == "function" then return PinType.Function
		elseif pinTpl.data_type == "delegate" then return PinType.Delegate
		else return PinType.Object end
	end

	--- 得到节点模板
	---@param node blueprint_node_data
	---@param builder blueprint_builder
	function handler.get_node_tpl(builder, node)
		local tplId = node.tplId
		for i, tpl in ipairs(builder.nodes) do 
			if tpl.name == tplId then 
				return tpl
			end
		end
	end

	--- 得到节点pin模板
	---@param node_tpl blueprint_node_tpl_data
	---@param pin blueprint_node_pin_data
	function handler.get_node_pin_tpl(pin, node_tpl)
		for i, tpl in ipairs(node_tpl.pins) do 
			if tpl.name == pin.key then 
				local type = handler.get_pin_type(tpl.type)
				if type == pin.type then 
					return tpl
				end
			end
		end
	end

	return handler
end 

return {create = create}