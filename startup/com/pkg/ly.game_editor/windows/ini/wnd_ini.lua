--------------------------------------------------------
-- ini文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local ed = dep.ed 
local ImGui = dep.ImGui

local function new(vfs_path, full_path)
	local api = {} 			---@class ly.game_editor.wnd_ini

	function api.update(deltatime)
		for i = 1, 15 do 
			if ImGui.Button("btn_test_" ..i) then 
				
			else 
				ImGui.SameLine()
				ImGui.Text("天姥连天向天横 势拔五岳掩赤城" .. vfs_path)
			end
		end
	end 

	function api.close()
	end 

	function api.save()
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return false
	end

	return api 
end


return {new = new}