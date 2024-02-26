---@class blueprint_node_pin_tpl_data -- 节点模板pin声明
local blueprint_node_pin_tpl_data = 
{
	---@type string pin类型, 有 input_flow, output_flow, input_var, output_var
	type = "",

	---@type string pin名字  
	name = "",

	---@type string 数据类型
	data_type = "",

	---@type string 数据默认值
	data_default = "",

	---@type any[] 其他数据
	meta = {}
}

---@class blueprint_node_tpl_data 节点模板声明
local node_declare_meta = 
{	
	---@type string 节点名字
	name = "",

	---@type string[] 属性列表
	attrs = {},

	---@type blueprint_node_pin_tpl_data[]
	pins = {},

	---@type string 节点显示类型 
	show_type = "",

	---@type string[] 分组信息
	groups = {}
}

---@class blueprint_node_pin_data
local blueprint_node_pin_data = 
{	
	---@type number 唯一id
	id = 0,

	---@type string 关键字
	key = "",

	---@type string 数据
	value = "",
}

---@class blueprint_node_data 节点编辑器数据
local blueprint_node_data = 
{	
	---@type number 唯一id
	id = 0;

	---@type string 模板名
	tplId = "",

	---@type number 位置x
	pos_x = 0;

	---@type number 位置y
	pos_y = 0;	

	---@type blueprint_node_pin_data[] 输入流
	input_flows = {},

	---@type blueprint_node_pin_data[] 输出流
	output_flows = {},

	---@type blueprint_node_pin_data[] 输入参数列表
	input_vars = {},

	---@type blueprint_node_pin_data[] 输出参数列表
	output_vars = {},

	---@type blueprint_node_pin_data[] 回调列表
	delegates = {},

	---@type blueprint_node_tpl_data 节点模板
	tpl = {}
}

---@class node_editor_create_args 编辑器创建参数说明
local node_editor_create_args = 
{
	---@type string 图的类型
	type = "",		

	---@type number 图数量
	graph_count = 1,

	---@type blueprint_builder 节点声明列表
	blueprint_builder = {},
}
