--------------------------------------------------------
-- def文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local uitls = require 'windows.utils'
local ImGui = dep.ImGui

local function new_data_handler()
	local handler = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	return handler
end

local function create()
	local api = {}
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = new_data_handler()
	api.data_hander = data_hander
	api.stack = stack

	function api.set_data(data)
		data_hander.data = data or {}
		stack.set_data_handler(data_hander)
		stack.snapshoot()
	end

	function api.update(delta_time)

	end

	return api
end

---@param editor ly.game_editor.editor
local function new(editor, vfs_path, full_path)
	local api = {} 			---@class ly.game_editor.wnd_def
	local main = create()

	function api.reload()
		main.set_data(uitls.load_file(full_path))
	end

	function api.update(delta_time)
		main.update(delta_time)
	end 

	function api.close()

	end 

	function api.save()
		uitls.save_file(full_path, main.data_hander)
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return main.data_hander.isModify
	end

	function api.handleKeyEvent()
		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
			if ImGui.IsKeyPressed(ImGui.Key.Z, false) then main.stack.undo() end
			if ImGui.IsKeyPressed(ImGui.Key.Y, false) then main.stack.redo() end
		end
	end

	api.reload()
	return api 
end


return {new = new}