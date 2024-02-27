local ecs = ...
local dep = require 'dep'  ---@type game.demo.dep
local ImGui  = dep.ImGui
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_11_system",
    category        = mgr.type_imgui,
    name            = "11_蓝图使用示例",
    file            = "imgui/imgui_11.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local blueprint = dep.blueprint
local ed = dep.ed
local editor 		---@type blueprint_graph_main
local size1 = 200

function system.on_entry()
	
	---@type node_editor_create_args
	local args = 
	{
		graph_count = 1,
		blueprint_builder = system.get_builder()
	}
	editor = blueprint.create_editor(args)
	editor.on_begin()

	editor.data_hander.create_node(200, 100, args.blueprint_builder.nodes[1])
	editor.data_hander.create_node(600, 100, args.blueprint_builder.nodes[2])
	editor.data_hander.create_node(100, 500, args.blueprint_builder.nodes[3])
	editor.data_hander.create_node(400, 500, args.blueprint_builder.nodes[4])
	editor.data_hander.create_node(600, 500, args.blueprint_builder.nodes[5])
	editor.data_hander.create_node(800, 500, args.blueprint_builder.nodes[6])
end 

function system.on_leave()
	editor.on_destroy()
	editor = nil
end

function system.data_changed()
	if not editor then return end 

	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local size2 = size_x - size1
		local newSize1, newSize2 = ed.Splitter(true, 6, size1, size2, 150, size_x * 0.5)
		if newSize1 then
			size1 = newSize1 
		end
		ImGui.SetCursorPos(size1 + 20, 8);
		editor.on_render(0.033);
	end
	ImGui.End()
end

function system.get_builder()
	local blueprint = dep.blueprint.blueprint_builder.create() ---@type blueprint_builder
	local def = dep.blueprint.def

	blueprint.create_node "MoveTo"
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		.add_input("Entry")
		.add_input_var("int", "count")
		.add_input_var("string", "name name name")

		.add_output("Exit")
		.add_output_var("int", "value")
		.add_output_var("string", "flag")
		.add_output_var("float", "test2 flag2")
		.add_output_var("object", "test2 flag2")
		.add_output_var("function", "v3")
		.add_output_var("delegate", "vd")
		
		.add_delegate("call", "回调1")


	blueprint.create_node "InputAction "
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		
		.add_output("Pressed")
		.add_output("Released")
		
		.add_delegate("call", "回调1")


	blueprint.create_node "InputAction2 "
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		.add_input("Pressed")
		.add_input("Released")
		.add_input_var("string", "flag")
		.add_input_var("float", "test2 flag2")
		.add_input_var("object", "test2 flag2")
		.add_input_var("function", "v3")
		.add_input_var("delegate", "vd")

		.add_output_var("string", "flag")
		.add_output_var("float", "test2 flag2")
		.add_output_var("object", "test2 flag2")
		.add_output_var("function", "v3")
		.add_output_var("delegate", "vd")
		.add_delegate("call", "回调1")


	blueprint.create_node "InputAction3 "
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		.add_input("Pressed")
		.add_input("Released")

	blueprint.create_node "InputAction4 "
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		.add_input("Entry")
		.add_output("Exit")

	blueprint.create_node "InputAction5 "
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		.add_output("Entry")
		.add_output("Exit")


	blueprint.on_create_complete()
	return blueprint
end