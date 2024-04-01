local dep = require "dep" ---@type ly.map.chess.dep
local ImGui = dep.ImGui
local lib = dep.common.lib
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
	editor.tb_object_def = args.tb_objects				---@type chess_object_tpl[]
		
	local draw = _chess_draw.create(editor)				---@type chess_editor_draw

	function editor.on_init()
		stack.set_data_handler(data_hander)	
		data_hander.init(args.data)
		editor.refresh_object_def()
		stack.snapshoot()
	end

	function editor.on_destroy()
		draw.on_destroy()
	end

	function editor.on_reset()
		local _args = dep.common.lib.copy(args)  		---@type chess_editor_create_args
		_args.data = nil
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
	end 

	function editor.handleKeyEvent()
		if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
			if ImGui.IsKeyPressed(ImGui.Key.Z, false) then stack.undo() end
			if ImGui.IsKeyPressed(ImGui.Key.Y, false) then stack.redo() end
		end
	end

	function editor.is_dirty()
		return data_hander.isModify;
	end

	function editor.refresh_object_def()
		if data_hander.has_path_def() then 
			local tbFile = dep.common.file.load_csv(data_hander.data.path_def)
			dep.common.lib.dump(tbFile)
			local list = {}
			for i, v in ipairs(tbFile) do 
				local data = {}
				data.id = tonumber(v.id) or 0
				if data.id > 0 then
					data.name = v.name or ""
					data.size = lib.string_to_vec2(v.size)
					data.bg_color = lib.eval(v.bg_color) or {0, 0, 0, 1}
					data.txt_color = lib.eval(v.txt_color) or {0.9, 0.9, 0.9, 1}
					table.insert(list, data)
				end
			end
			editor.tb_object_def = list
		end
		data_hander.refresh_path_def(editor.tb_object_def)
	end
	
	editor.on_init()
	return editor
end 

return {create = create}