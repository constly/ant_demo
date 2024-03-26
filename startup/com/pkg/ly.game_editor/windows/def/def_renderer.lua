--------------------------------------------------------
-- def 窗口渲染
--------------------------------------------------------

---@param editor ly.game_editor.editor
---@param data_hander ly.game_editor.def.handler
---@param stack common_data_stack
local function new(editor, data_hander, stack)
	---@class ly.game_editor.def.renderer
	local api = {}
	api.data_hander = data_hander
	api.stack = stack

	function api.set_data(data)
		data_hander.data = data or {}
		stack.set_data_handler(data_hander)
		stack.snapshoot()
	end

	function api.update(delta_time)

	end

	return api
end

return {new = new}