local dep = require "dep" ---@type ly.map.chess.dep
local ImGui = dep.ImGui
local editor_draw = require 'editor.editor_draw'
local data_hander = require 'common.data_handler'

---@param args chess_editor_create_args
local create = function(args)
	---@class chess_editor
	local editor = {}	
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = data_hander.create()			---@type chess_data_handler
	local draw = editor_draw.create(editor)		---@type chess_editor_draw

	function editor.on_init()
		stack.set_data_handler(data_hander)	
		data_hander.init(args)
		stack.snapshoot()
	end

	function editor.on_reset()
		data_hander.init(args)
		stack.snapshoot()
	end


	function editor.on_render(deltatime)
		draw.on_render(deltatime)

		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
			if ImGui.IsKeyPressed(ImGui.Key.Z, false) then stack.undo() end
			if ImGui.IsKeyPressed(ImGui.Key.Y, false) then stack.redo() end
		end
	end 
	return editor
end 

return {create = create}