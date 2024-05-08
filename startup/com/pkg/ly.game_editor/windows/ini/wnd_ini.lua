--------------------------------------------------------
-- ini文件编辑器
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local uitls = require 'windows.utils'
local ini_renderer = require 'windows.ini.ini_renderer'
local ImGui = dep.ImGui

---@type ly.game_core
local game_core = import_package 'ly.game_core'


---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 										---@class ly.game_editor.wnd_ini
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = game_core.create_ini_handler()	---@type ly.game_editor.ini.handler
	local renderer = ini_renderer.new(editor, data_hander, stack)	---@type ly.game_editor.ini.renderer

	function api.update(is_active, delta_time)
		renderer.update(delta_time)
		if is_active then 
			if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
				if ImGui.IsKeyPressed(ImGui.Key.Z, false) then stack.undo() end
				if ImGui.IsKeyPressed(ImGui.Key.Y, false) then stack.redo() end
				if ImGui.IsKeyPressed(ImGui.Key.S, false) then 
					api.save() 
					editor.msg_hints.show("保存成功", "ok")
				end
			end
		end
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return data_hander.isModify
	end

	function api.reload()
		renderer.set_data(dep.common.file.load_datalist(full_path))
	end

	function api.close()
	end 

	function api.save()
		uitls.save_file(full_path, data_hander, stack)
		editor.wnd_mgr.when_file_save_complete(self, vfs_path, full_path)
	end 

	api.reload()
	return api 
end

return {new = new}