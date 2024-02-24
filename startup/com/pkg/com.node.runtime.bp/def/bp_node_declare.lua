---@type com.node.runtime.api
local runtime = import_package("com.node.runtime")  
local node_declare = runtime.node_declare

---@type node_builder_declare
local declare = node_declare.create()

------------------------------------------------------------------------
--- 数学
------------------------------------------------------------------------
declare.create_node "test"
	.set_attr("key", "value")
	.set_category()
	.set_type()
	.set_group()
	.add_input()
	.add_output()
	.add_input_var()
	.add_output_var()


------------------------------------------------------------------------
--- 渲染
------------------------------------------------------------------------


------------------------------------------------------------------------
--- 动画
------------------------------------------------------------------------

return {get = function() return declare end}