local ecs = ...
local dep = require "dep" ---@type game.demo.dep
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "designer_06_system",
    category        = mgr.type_designer,
    name            = "06_地图编辑器",
    file            = "designer/designer_06.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local ImGui = dep.ImGui
---@type chess_editor
local editor 

---@type chess_object_tpl[] 物件定义
local tb_object_def = 
{
	{id = 1, name = "地面", size = {x = 1, y = 1}, bg_color = {0.35, 0.35, 0.35, 1}, txt_color = {0, 0, 0, 0}},
	{id = 2, name = "草原", size = {x = 1, y = 1}, bg_color = {0.3, 0.3, 0.3, 1}, txt_color = {0, 0.8, 0, 1}},
	{id = 3, name = "阻挡", size = {x = 1, y = 1}, bg_color = {0.8, 0.8, 0.8, 1}, txt_color = {0, 0.8, 0, 1}},
	{id = 4, name = "饭店", size = {x = 2, y = 2}, bg_color = {0.8, 0.8, 0.8, 1}, txt_color = {0, 0.8, 0, 1}},
	{id = 5, name = "别墅", size = {x = 3, y = 3}, bg_color = {0.8, 0.8, 0.8, 1}, txt_color = {0, 0.8, 0, 1}},
	{id = 99, name = "出生点", size = {x = 1, y = 1}, bg_color = {0.3, 0.3, 0.3, 1}, txt_color = {1, 1, 0, 1}},
}

function system.on_entry()
	if not editor then 
		---@type chess_editor_create_args
		local params = {}
		params.path = ""
		params.tb_objects = tb_object_def
		editor = dep.chess_map.create(params);
	end
end

function system.on_leave()
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		local size_x, size_y = ImGui.GetContentRegionAvail()
		size_x = size_x - 100
		size_y = size_y - 50
		ImGui.SetCursorPos(100, 30)
		ImGui.BeginChild("##child", size_x, size_y, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"})
			editor.on_render(0.033)	
		ImGui.EndChild()	
	end 
	ImGui.End()
end