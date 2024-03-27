--------------------------------------------------------
-- ini文件编辑器
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local uitls = require 'windows.utils'
local ini_handler = require 'windows.ini.ini_handler'
local ini_renderer = require 'windows.ini.ini_renderer'
local ImGui = dep.ImGui


---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 										---@class ly.game_editor.wnd_ini
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = ini_handler.new()				---@type ly.game_editor.ini.handler
	local renderer = ini_renderer.new(editor, data_hander, stack)	---@type ly.game_editor.ini.renderer

	function api.update(delta_time)
		renderer.update(delta_time)
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return data_hander.isModify
	end

	function api.handleKeyEvent()
		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
			if ImGui.IsKeyPressed(ImGui.Key.Z, false) then stack.undo() end
			if ImGui.IsKeyPressed(ImGui.Key.Y, false) then stack.redo() end
			if ImGui.IsKeyPressed(ImGui.Key.S, false) then 
				api.save() 
				editor.msg_hints.show("保存成功", "ok")
			end
		end
	end

	function api.reload()
		renderer.set_data(uitls.load_datalist(full_path))
	end

	function api.close()
	end 

	function api.save()
		uitls.save_file(full_path, data_hander, stack)
	end 

	api.reload()
	return api 
end

return {new = new}