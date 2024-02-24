---@class node_declare 节点声明
local node_declare_meta = 
{
	---@type string[] 属性列表
	attrs = {},

	---@type string 节点类型 
	type = "",

	-- 等待
}


---@class node_declare_builder 节点声明构造器
local builder = {}
local data 
local set_builder_data = function(_data)
	data = _data
	return builder
end

---@return node_declare_builder
function builder.set_attr(key, value)
	data.attrs[key] = value
	return builder
end

---@return node_declare_builder
function builder.set_type(type)
	data.type = type
	return builder
end

---@return node_declare_builder
function builder.set_group(group)
	data.group = group
	return builder
end

---@return node_declare_builder
function builder.set_category(category)
	data.category = category
	return builder
end 

---@return node_declare_builder
function builder.add_input(name, desc)
	return builder
end

---@return node_declare_builder
function builder.add_input_var(type, name, desc, default)
	return builder
end

---@return node_declare_builder
function builder.add_output(name, desc)
	return builder
end

---@return node_declare_builder
function builder.add_output_var(type, name, desc)
	return builder
end



local create = function()
	---@class node_builder_declare
	local declare = {}

	---@type node_declare[]
	declare.nodes = {}

	---@return node_declare_builder
	function declare.create_node(name)
		local node = {attrs = {}}
		table.insert(declare.nodes, node)
		return set_builder_data(node)
	end

	-- 当创建完成后，需要做一些处理
	function declare.on_create_complete()
		set_builder_data(nil)

		-- 遍历节点
	end

	return declare
end 

return {create = create}
