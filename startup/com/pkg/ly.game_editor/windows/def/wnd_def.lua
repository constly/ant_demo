--------------------------------------------------------
-- def文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local uitls = require 'windows.utils'
local def_handler = require 'windows.def.def_handler'
local def_renderer = require 'windows.def.def_renderer'
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 										---@class ly.game_editor.wnd_def
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = def_handler.new()				---@type ly.game_editor.def.handler
	local renderer = def_renderer.new(editor, data_hander, stack)	---@type ly.game_editor.def.renderer

	function api.reload()
		renderer.set_data(uitls.load_datalist(full_path))
	end

	function api.update(is_active, delta_time)
		renderer.update(delta_time)
		if is_active then 
			if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
				if ImGui.IsKeyPressed(ImGui.Key.Z, false) then stack.undo() end
				if ImGui.IsKeyPressed(ImGui.Key.Y, false) then stack.redo() end
				if ImGui.IsKeyPressed(ImGui.Key.S, false) then api.save() end
			end
		end
	end 

	function api.close()

	end 

	function api.save()
		uitls.save_file(full_path, data_hander, stack)
		editor.wnd_mgr.when_file_save_complete(self, vfs_path, full_path)
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return data_hander.isModify
	end

	api.reload()
	return api 
end

return {new = new}