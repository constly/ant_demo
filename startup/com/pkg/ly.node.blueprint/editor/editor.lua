---------------------------------------------------------------------------
-- 蓝图编辑器
---------------------------------------------------------------------------
local dep = require "dep" ---@type ly.node.blueprint.dep
local ImGui = dep.ImGui
local graph_draw = require 'editor.graph_draw'
local data_hander = require 'common.data_handler'

---@param args node_editor_create_args
local create = function(args)
	---@class blueprint_editor
	local editor = {}									
	local stack = dep.common.data_stack.create()		---@type common_data_stack
	local data_hander = data_hander.create()			---@type blueprint_data_handler
	local graph_draw = graph_draw.create(editor)		---@type blueprint_graph_draw
	local stack_version = 0
	local _navigateToContent = false

	editor.args = args									---@type node_editor_create_args
	editor.blueprint_builder = args.blueprint_builder	---@type blueprint_builder
	editor.stack = stack
	editor.data_hander = data_hander
	
	function editor.on_init()
		stack.set_data_handler(data_hander)	
		data_hander.init(args)
		stack.snapshoot()
		graph_draw.on_init()
	end

	function editor.on_reset()
		data_hander.init(args)
		stack.snapshoot()
	end

	function editor.on_begin()

	end 

	function editor.on_save(write_callback)
		local old = data_hander.data.__dirty
		data_hander.data.__dirty = nil
		local content = dep.serialize.stringify(data_hander.data)
		data_hander.data.__dirty = old
		data_hander.isModify = false
		write_callback(content)
	end

	function editor.set_data(data)
		data_hander.data = data
		stack.snapshoot(true)
	end

	function editor.on_destroy()
		graph_draw.on_destroy()
	end 

	function editor.navigateToContent()
		_navigateToContent = true
	end

	function editor.on_render(deltatime)
		local data = data_hander.get_cur_graph()
		if data then
			local needReload = false
			if stack_version ~= data_hander.stack_version then 
				stack_version = data_hander.stack_version
				needReload = true
			end
			local params = {
				needReload = needReload,
				navigateToContent = _navigateToContent,
			}
			graph_draw.on_render(data, deltatime, params)

			-- 快捷键
			if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
				if ImGui.IsKeyPressed(ImGui.Key.Z, false) then stack.undo() end
				if ImGui.IsKeyPressed(ImGui.Key.Y, false) then stack.redo() end
				
				--if ImGui.IsKeyPressed(ImGui.Key.C, false) then clipboard.copy() end
				--if ImGui.IsKeyPressed(ImGui.Key.V, false) then clipboard.paste() end
				--if ImGui.IsKeyPressed(ImGui.Key.X, false) then clipboard.cut() end
			end

			_navigateToContent = false
		end
	end

	editor.on_init()
	return editor
end 


return {create = create}