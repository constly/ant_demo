--------------------------------------------------------
-- map文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 			---@class ly.game_editor.wnd_map
	
	---@type chess_editor
	local main = nil 

	local function init()
		local f<close> = io.open(full_path, 'r')
		local data = f and dep.datalist.parse( f:read "a" )
	
		---@type chess_editor_create_args
		local params = {}
		params.data = data
		main = require 'windows.map.map_renderer'.new(params);
	end

	function api.update(is_active, delta_time, show_mode)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("##child", size_x, size_y, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"})
			if show_mode == 2 then 
				ImGui.Text("预览模式")
			else 
				main.on_render(is_active, delta_time)
			end
		ImGui.EndChild()
		if is_active then 
			main.handleKeyEvent()
			if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
				if ImGui.IsKeyPressed(ImGui.Key.S, false) then api.save() end
			end
		end
	end 

	function api.close()
		main.on_destroy()
	end 

	function api.save()
		main.on_save(function(content)
			local f<close> = assert(io.open(full_path, "w"))
			f:write(content)
		end)
		editor.wnd_mgr.when_file_save_complete(self, vfs_path, full_path)
	end

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return main.is_dirty()
	end

	function api.onAnyFileSaveComplete(_vfs_path, _full_path)
		if _vfs_path == main.data_hander.data.path_def then 
			print("onAnyFileSaveComplete", _vfs_path, _full_path)
			main.refresh_object_def()
		end
	end

	function api.reload()
		main.on_reset()
	end

	---@return boolean 是否有预览模式
	function api.has_preview_mode()
		return true
	end 

	init()
	return api 
end


return {new = new}