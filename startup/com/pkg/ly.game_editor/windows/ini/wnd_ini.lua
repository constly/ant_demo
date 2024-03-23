--------------------------------------------------------
-- ini文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local ed = dep.ed 
local ImGui = dep.ImGui

local function new(path)
	local api = {} 			---@class ly.game_editor.wnd_ini
	api.path = path			---@type string 文件路径
	api.is_dirty = false	---@type boolean 文件是否有修改

	function api.open(path)
	end 
	
	function api.update(deltatime)
		for i = 1, 15 do 
			if ImGui.Button("btn_test_" ..i) then 
				
			else 
				ImGui.SameLine()
				ImGui.Text("天姥连天向天横 势拔五岳掩赤城" .. path)
			end
		end
	end 

	function api.close()
	end 

	function api.save()
	end 

	return api 
end


return {new = new}