local dep = require "dep" ---@type ly.map.chess.dep
local ImGui = dep.ImGui
local _chess_draw = require 'editor.chess_draw'
local _data_hander = require 'common.data_handler'

---@param args chess_editor_create_args
local create = function(args)
	---@class chess_editor
	local editor = {}	
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = _data_hander.create() 			---@type chess_data_handler
	editor.data_hander = data_hander
	editor.stack = stack
	editor.args = args
		
	local draw = _chess_draw.create(editor)				---@type chess_editor_draw

	function editor.on_init()
		stack.set_data_handler(data_hander)	
		data_hander.init(args)
		stack.snapshoot()
	end

	function editor.on_destroy()
		draw.on_destroy()
	end

	function editor.on_reset()
		local _args = dep.common.lib.copy(args)  		---@type chess_editor_create_args
		_args.path = nil
		data_hander.init(_args)
		stack.snapshoot()
	end

	function editor.on_save(write_callback)
		local cache = data_hander.data.cache
		data_hander.data.cache = {}
		local content = dep.serialize.stringify(data_hander.data)
		data_hander.data.cache = cache
		data_hander.isModify = false
		write_callback(content)
	end

	function editor.on_render(deltatime)
		draw.on_render(deltatime)

		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
			if ImGui.IsKeyPressed(ImGui.Key.Z, false) then stack.undo() end
			if ImGui.IsKeyPressed(ImGui.Key.Y, false) then stack.redo() end
		end
	end 
	
	editor.on_init()
	return editor
end 

return {create = create}