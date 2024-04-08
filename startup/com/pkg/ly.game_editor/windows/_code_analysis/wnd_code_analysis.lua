--------------------------------------------------------
-- code analysis 代码分析
--------------------------------------------------------
local dep = require 'dep'
local uitls = require 'windows.utils'
local code_handler = require 'windows._code_analysis.code_handler'
local code_renderer = require 'windows._code_analysis.code_renderer'
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 																---@class ly.game_editor.wnd_style
	local stack = dep.common.data_stack.create()								---@type common_data_stack
	local data_hander = code_handler.new(editor)								---@type ly.game_editor.code.handler
	local renderer = code_renderer.new(editor, data_hander, stack)				---@type ly.game_editor.code.renderer

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
			end
		end
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return false
	end

	function api.reload()
		renderer.reload()
	end

	function api.close()
	end 

	function api.save()
	end 

	init()
	api.reload()
	return api 
end


return {new = new}