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
local editor 		---@type blueprint_editor
local size1 = 200
local bp_builder
local file_path = dep.common.path_def.cache_root .. "imgui_11.bp_data"

function system.on_entry()
	if not bp_builder then 
		bp_builder = system.get_builder()
	end
	if not editor then
		---@type node_editor_create_args
		local args = 
		{
			graph_count = 1,
			blueprint_builder = bp_builder
		}
		editor = blueprint.create_editor(args)
		editor.on_begin()
		system.create_nodes()
		editor.stack.snapshoot()
	end
	editor.navigateToContent()
end 

function system.create_nodes()
	local handler = editor.data_hander
	handler.create_node(100, 100, bp_builder.nodes[1])
	handler.create_node(450, 30, bp_builder.nodes[2])
	handler.create_node(50, 340, bp_builder.nodes[3])
	handler.create_node(400, 350, bp_builder.nodes[4])
	handler.create_node(450, 450, bp_builder.nodes[5])
	handler.create_node(700, 450, bp_builder.nodes[6])
	
	local graph_data = handler.get_cur_graph()
	table.insert(graph_data.links, {id = handler.next_id(), startPin = 2, endPin = 6, type = 4})
	table.insert(graph_data.links, {id = handler.next_id(), startPin = 23, endPin = 4, type = 0})
end

function system.on_leave()
	-- 销毁接口
	-- editor.on_destroy()
	-- editor = nil
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
		ImGui.SetCursorPos(30, 50)
		ImGui.BeginGroup()
		local size = 90 * mgr.get_dpi_scale()
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ItemSpacing, 10, 10);
		ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
		ImGui.Text("数据堆栈版本: " .. editor.data_hander.stack_version)
		if ImGui.ButtonEx("保 存", size) then 
			editor.on_save(function(content)
				local f<close> = assert(io.open(file_path, "w"))
    			f:write(content)
			end)
			print("save to:", file_path)
			os.execute("code ".. file_path)
		end
		if ImGui.ButtonEx("加 载", size) then 
			local f<close> = io.open(file_path, 'r')
    		if f then 
        		local content = f:read "a"
				local data = dep.datalist.parse(content)
				editor.set_data(data) 
    		end 
		end

		ImGui.Dummy(10, 10)
		if ImGui.ButtonEx("撤 销", size) then 
			editor.stack.undo();
		end
		if ImGui.ButtonEx("回 退", size) then 
			editor.stack.redo();
		end

		ImGui.Dummy(10, 10)
		if ImGui.ButtonEx("清空数据", size) then 
			editor.on_reset();
		end
		if ImGui.ButtonEx("重置数据", size) then 
			editor.on_reset();
			system.create_nodes();
			editor.stack.pop()
			editor.stack.snapshoot()
		end

		ImGui.Dummy(10, 10)
		if ImGui.ButtonEx("视野回正", size) then 
			editor.navigateToContent()
		end
		ImGui.PopStyleVar(1);
		ImGui.PopStyleColorEx(3);
		ImGui.EndGroup()

		ImGui.SetCursorPos(size1 + 20, 8);
		editor.on_render(0.033);
	end
	ImGui.End()
end

function system.get_builder()
	local blueprint = dep.blueprint.blueprint_builder.create() ---@type blueprint_builder
	local def = dep.blueprint.def
	
	blueprint.create_node "Input String "
		.set_show_type(def.type_simple)
		.set_group("default", "test")
		.set_attr("key", "value")		
		.add_output_var("string", "flag")

	blueprint.create_node "MoveTo"
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		.add_input("Entry")
		.add_input_var("int", "count")
		.add_input_var("string", "name name name")

		.add_output("Exit")
		.add_output_var("int", "speed")
		.add_output_var("string", "tag")
		.add_output_var("float", "time", "移动时间")
		.add_output_var("object", "target", "目标点")
		.add_output_var("function", "update", "更新")
		.add_output_var("delegate", "complete", "移动完成回调")
		
		.add_delegate("call", "回调1")
	

	blueprint.create_node "TakeDamage "
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		.set_header_color({0.2, 0.6, 0.95, 1})
		.add_input("Entry")
		.add_input_var("int", "damage")
		.add_input_var("string", "npc tags")
		.add_input_var("float", "rate")
		.add_input_var("object", "ignore")
		.add_input_var("function", "check")
		.add_input_var("delegate", "complete")

		.add_output("Exit")
		.add_output_var("int", "damage")
		.add_output_var("string", "log")
		.add_output_var("float", "damage float")
		.add_output_var("object", "npc object")
		.add_output_var("function", "function")
		.add_output_var("delegate", "delegate")
		

	blueprint.create_node "填写注释"
		.set_show_type(def.type_comment)
		.set_group("default", "test")
		.set_size(500, 300)
		

	blueprint.create_node "当开火时"
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_header_color({0.8, 0, 0, 1})
		.set_attr("key", "value")
		.add_output("Pressed")
		.add_output("Released")
		.add_delegate("call", "回调1")


	blueprint.create_node "OnEnd "
		.set_show_type(def.type_blueprint)
		.set_group("default", "test")
		.set_attr("key", "value")
		.add_input("Entry")


	blueprint.on_create_complete()
	return blueprint
end