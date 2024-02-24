local ecs = ...
local ImGui  = require "imgui"
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
local node_editor = import_package("com.node.editor")
local node_rumtime_bp = import_package "com.node.runtime.bp"  ---@type com.node.runtime.bp.api
local ed = require "imgui.node_editor"
local editor 		---@type blueprint_graph_main
local size1 = 200

function system.on_entry()
	---@type node_editor_create_args
	local args = 
	{
		type = "blueprint",
		subgraph = 1,
		node_declares = node_rumtime_bp.node_declare.get();
	}
	editor = node_editor.create(args)
	editor.on_begin()
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