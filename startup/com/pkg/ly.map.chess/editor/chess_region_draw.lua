local dep = require 'dep' ---@type ly.map.chess.dep
local ImGui = dep.ImGui

---@param editor chess_editor
---@return chess_region_draw
local create = function(editor)
	---@class chess_region_draw
	local api = {}
	local region 	---@type chess_map_region_tpl

	function api.on_render(deltatime)
		region = editor.data_hander.cur_region()
		
		ImGui.Text("Draw Content");
	end

	return api
end 


return {create = create}