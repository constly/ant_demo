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
local imgui_utils = dep.common.imgui_utils
local file_path = dep.common.path_def.data_root .. "/chess/map_01.map"

---@type chess_editor
local editor 

---@type chess_object_tpl[] 物件定义
local tb_object_def = 
{
	{id = 1, name = "地面", size = {x = 1, y = 1}, bg_color = {45, 45, 45,255}, txt_color = {200, 200, 200}},
	{id = 2, name = "阻挡", size = {x = 1, y = 1}, bg_color = {180, 0, 0}, txt_color = {0, 0, 0}},
	{id = 3, name = "空地", size = {x = 1, y = 1}, bg_color = {70,50,30}, txt_color = {255,255,255}},

	{id = 10, name = "内政", size = {x = 1, y = 1}, bg_color = {128,225,242,255}, txt_color = {0,0,0}},
	{id = 11, name = "战斗", size = {x = 1, y = 1}, bg_color = {241,133,208,255}, txt_color = {0,0,0}},
	{id = 12, name = "外交", size = {x = 1, y = 1}, bg_color = {242,241,128,255}, txt_color = {200,45,0}},
	{id = 13, name = "传送门", size = {x = 1, y = 1}, bg_color = {241,133,208,255}, txt_color = {200,25,0}},
	{id = 14, name = "休息", size = {x = 1, y = 1}, bg_color = {205,133,63}, txt_color = {0,0,0}},
	{id = 15, name = "陷阱", size = {x = 1, y = 1}, bg_color = {255,255,255,128}, txt_color = {0,0,0}},

	{id = 20, name = "抽奖", size = {x = 1, y = 1}, bg_color = {75,0,0,255}, txt_color = {200,0,0}},
	{id = 21, name = "寻路", size = {x = 1, y = 1}, bg_color = {75,75,75,255}, txt_color = {200,200,200}},

	{id = 30, name = "写字楼", size = {x = 2, y = 2}, bg_color = {100,80,60}, txt_color = {255,255,255}},

	{id = 99, name = "出生点", size = {x = 1, y = 1}, bg_color = {128,128,128,200}, txt_color = {240,240,0}},
}
for i, v in ipairs(tb_object_def) do 
	local process = function(tb)
		for i, t in ipairs(tb) do 
			tb[i] = t / 255
		end
		tb[4] = tb[4] or 1
	end
	process(v.bg_color)
	process(v.txt_color)
end


function system.on_entry()
	if not editor then 
		local f<close> = io.open(file_path, 'r')
		local data = f and dep.datalist.parse( f:read "a" )
		
		---@type chess_editor_create_args
		local params = {}
		params.data = data
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
		ImGui.SetCursorPos(5, 30)
		ImGui.BeginChild("##child", size_x, size_y, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"})
			editor.on_render(true, 0.033)	
			editor.handleKeyEvent()
		ImGui.EndChild()	

		ImGui.SetCursorPos(size_x + 20, 30)
		ImGui.BeginGroup()
		if imgui_utils.draw_btn("Reload##btn_reload", false, {size_x = 80}) then 
			editor.on_init()
		end 
		if imgui_utils.draw_btn("Save##btn_save", false, {size_x = 80}) then 
			editor.on_save(function(content)
				local f<close> = assert(io.open(file_path, "w"))
    			f:write(content)
			end)
		end 
		if imgui_utils.draw_btn("Clear##btn_clear", false, {size_x = 80}) then 
			editor.on_reset()
		end 
		ImGui.EndGroup()
	end 
	ImGui.End()
end