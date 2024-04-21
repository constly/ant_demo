local function new()
	---@class sims.debug.wnd_saved
	local api = {}
	local ImGui  = require "imgui"

	---@param _editor ly.game_editor.editor
	function api.init(_editor)
		
	end

	function api.update(is_active, delta_time)
		ImGui.Text("111")
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return false
	end

	function api.reload()
		
	end

	function api.close()
	end 

	function api.save()
	end 

	return api
end

return {new = new}