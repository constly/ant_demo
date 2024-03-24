--------------------------------------------------------
-- csv文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local ed = dep.ed 
local ImGui = dep.ImGui

local function new(vfs_path, full_path)
	local api = {} 				---@class ly.game_editor.wnd_csv
	
	function api.update(delta_time)
		ImGui.Text("csv 绘制")
	end 

	function api.close()
	end 

	function api.save()
	end 

	function api.is_dirty()
		return false
	end

	function api.reload()
	end

	function api.handleKeyEvent()
		
	end
	
	return api 
end


return {new = new}