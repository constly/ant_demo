
-- 图数据处理器
local create = function()
	---@class chess_data_handler
	---@field data chess_map_tpl 棋盘模板id
	---@field stack_version number 堆栈版本号,当堆栈版本号发生变化时，需要刷新编辑器
	---@field isModify boolean 数据是否有变化
	local handler = {
		data = {},
		stack_version = 0,
		isModify = false,
	}

	---@param args chess_editor_create_args
	function handler.init(args)
		local data = {} ---@type chess_map_tpl
		data.next_id = 0;
		data.regions = {}
		handler.data = data
	end

	function handler.next_id()
		local data = handler.data 
		data.next_id = data.next_id + 1; 
		return data.next_id
	end
end 

return {create = create}