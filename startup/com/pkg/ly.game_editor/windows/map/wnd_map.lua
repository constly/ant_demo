--------------------------------------------------------
-- map文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local ed = dep.ed 
local ImGui = dep.ImGui

---@type ly.map.chess.main
local chess_map = import_package 'ly.map.chess'			

---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 			---@class ly.game_editor.wnd_map
	
	---@type chess_editor
	local main = nil 

	local function init()
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

		local f<close> = io.open(full_path, 'r')
		local data = f and dep.datalist.parse( f:read "a" )
	
		---@type chess_editor_create_args
		local params = {}
		params.data = data
		params.tb_objects = tb_object_def
		if not main then 
			main = chess_map.create(params);
		end
	end

	function api.update(delta_time)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("##child", size_x, size_y, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"})
			main.on_render(delta_time)
		ImGui.EndChild()
	end 

	function api.close()
		main.on_destroy()
	end 

	function api.save()
		main.on_save(function(content)
			local f<close> = assert(io.open(full_path, "w"))
			f:write(content)
		end)
	end

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return main.is_dirty()
	end

	function api.handleKeyEvent()
		main.handleKeyEvent()
	end

	function api.reload()
	end

	init()
	return api 
end


return {new = new}