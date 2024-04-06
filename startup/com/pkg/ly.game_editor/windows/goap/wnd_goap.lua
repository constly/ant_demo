--------------------------------------------------------
-- goap 文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local uitls = require 'windows.utils'
local goap_handler = require 'windows.goap.goap_handler'
local goap_renderer = require 'windows.goap.goap_renderer'
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 																---@class ly.game_editor.wnd_goap
	local stack = dep.common.data_stack.create()								---@type common_data_stack
	local data_hander = goap_handler.new()										---@type ly.game_editor.goap.handler
	local renderer = goap_renderer.new(editor, data_hander, stack)				---@type ly.game_editor.goap.renderer

	local function init()
		stack.set_data_changed_notify(function(dirty)
			if dirty then 
				
			end
		end)
	end

	function api.update(is_active, delta_time)
		renderer.update(delta_time)

		if is_active then 
			if ImGui.IsPopupOpen("", ImGui.PopupFlags{'AnyPopup'}) then 
				return 
			end
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
		renderer.set_data(uitls.load_datalist(full_path))
		stack.on_data_changed(true)
	end

	function api.close()
	end 

	function api.save()
		uitls.save_file(full_path, data_hander, stack)
	end 

	init()
	api.reload()
	return api 
end


return {new = new}