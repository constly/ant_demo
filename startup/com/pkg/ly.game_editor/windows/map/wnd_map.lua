--------------------------------------------------------
-- map文件编辑器
--------------------------------------------------------
local dep = require 'dep'
local ed = dep.ed 
local ImGui = dep.ImGui

local function new(path)
	local api = {} 			---@class ly.game_editor.wnd_map
	api.path = path			---@type string 文件路径
	api.is_dirty = false	---@type boolean 文件是否有修改

	function api.open(path)
	end 
	
	function api.update(deltatime)
		ImGui.Text("地图绘制 " .. path)
	end 

	function api.close()
	end 

	function api.save()
	end 

	return api 
end


return {new = new}