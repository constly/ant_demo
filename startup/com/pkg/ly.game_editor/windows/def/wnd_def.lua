--------------------------------------------------------
-- def文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui

local function new_editor()
	local api = {}
	api.data = {}

	function api.set_data(data)
		api.data = data or {}
	end

	function api.update(delta_time)
	end

	return api
end


local function new(vfs_path, full_path)
	local api = {} 			---@class ly.game_editor.wnd_def
	local editor = new_editor()

	function api.reload()
		local f<close> = io.open(full_path, 'r')
		local data = f and dep.datalist.parse( f:read "a" )
		editor.set_data(data)
	end

	function api.update(delta_time)
		editor.update(delta_time)
	end 

	function api.close()

	end 

	function api.save()
		local content = dep.serialize.stringify(editor.data)
		local f<close> = assert(io.open(full_path, "w"))
		f:write(content)
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return true
	end

	api.reload()
	return api 
end


return {new = new}