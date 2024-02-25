------------------------------------------------------------------------
--- 蓝图节点构造器
------------------------------------------------------------------------

---@class blueprint_node_builder 节点声明构造器
local builder = {}

---@type blueprint_node_tpl_data
local data 
local set_builder_data = function(_data)
	data = _data
	return builder
end

---@return blueprint_node_builder
function builder.set_attr(key, value)
	data.attrs[key] = value
	return builder
end

---@return blueprint_node_builder
function builder.set_show_type(type)
	data.show_type = type
	return builder
end

---@return blueprint_node_builder
function builder.set_group(...)
	data.groups = {...}
	return builder
end

---@return blueprint_node_builder
function builder.add_input(name, desc)
	table.insert(data.pins, {type = "input_flow", name = name, desc = desc})
	return builder
end

---@return blueprint_node_builder
function builder.add_input_var(data_type, name, desc, default, meta)
	table.insert(data.pins, {type = "input_var", data_type = data_type, name = name, desc = desc, default = default, meta})
	return builder
end

---@return blueprint_node_builder
function builder.add_output(name, desc)
	table.insert(data.pins, {type = "output_flow", name = name, desc = desc})
	return builder
end

---@return blueprint_node_builder
function builder.add_output_var(data_type, name, desc, meta)
	table.insert(data.pins, {type = "output_var", data_type = data_type, name = name, desc = desc, meta})
	return builder
end

local create = function()
	---@class blueprint_builder
	local blueprint = {}

	---@type blueprint_node_tpl_data[] 节点列表
	blueprint.nodes = {}

	-- 节点类型定义
	blueprint.type_blueprint = "blueprint"
	blueprint.type_simple = "simple"
	blueprint.type_tree = "tree"
	blueprint.type_comment = "comment"
	blueprint.type_houdini = "houdini"

	---@return blueprint_node_builder
	function blueprint.create_node(name)
		local node = {
			name = name,
			attrs = {}, 
			pins = {},
		}
		table.insert(blueprint.nodes, node)
		return set_builder_data(node)
	end

	-- 当创建完成后，需要做一些处理
	function blueprint.on_create_complete()
		set_builder_data(nil)

		-- 遍历节点
	end

	return blueprint
end 

return {create = create}
