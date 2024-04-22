--------------------------------------------------------
-- goap 文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local uitls = require 'windows.utils'
local goap_renderer = require 'windows.goap.goap_renderer'
local goap_clipboard = require 'windows.goap.goap_clipboard'
local ImGui = dep.ImGui
---@type ly.game_core
local game_core = import_package 'ly.game_core'

---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 																---@class ly.game_editor.wnd_goap
	local stack = dep.common.data_stack.create()								---@type common_data_stack
	local data_hander = game_core.create_goap_handler(vfs_path)					---@type ly.game_core.goap.handler
	local clipboard = goap_clipboard.new(editor, data_hander)					---@type ly.game_editor.goap.clipboard
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
				
				if ImGui.IsKeyPressed(ImGui.Key.C, false) then clipboard.copy() end
				if ImGui.IsKeyPressed(ImGui.Key.X, false) then clipboard.cut() end
				if ImGui.IsKeyPressed(ImGui.Key.V, false) then 
					if clipboard.paste() then 
						stack.snapshoot(true)
					end
				end

				if ImGui.IsKeyPressed(ImGui.Key.S, false) then 
					api.save() 
					editor.msg_hints.show("保存成功", "ok")
				end
			end
			if ImGui.IsKeyPressed(ImGui.Key.Delete, false) then  
				if data_hander.reset_all_selected() then 
					stack.snapshoot(true)
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

	---@return string[] 得到所有相关文件
	function api.get_all_related_files()
		local files = {}
		local setting = data_hander.data.settings
		if setting then 
			if setting.tag then table.insert(files, setting.tag) end 
			if setting.attr then table.insert(files, setting.attr) end 
		end
		return files
	end

	---@param file string 通知相关文件发生变化,file为变化的文件
	function api.notify_related_files_changed(file)
		local settings = data_hander.data.settings
		if settings.attr == file then 
			data_hander.reload_attr_handler()
		end
	end

	function api.save()
		uitls.save_file(full_path, data_hander, stack)
		editor.wnd_mgr.when_file_save_complete(self, vfs_path, full_path)
	end 

	init()
	api.reload()
	return api 
end


return {new = new}