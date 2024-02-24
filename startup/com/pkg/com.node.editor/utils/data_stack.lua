
-- 深拷贝table
local copy;
copy = function(tb)
	local ret = {};
	if type(tb) ~= "table" then
		return tb;
	end
	for k, v in pairs(tb) do
		if type(v) == "table" then
			ret[k] = copy(v);
		else
			ret[k] = v;
		end
	end
	return ret;
end


local create = function()
	-- 数据堆栈
	---@class node_editor_data_stack
	local data_stack = {}
	local data_hander
	local index = 0
	local stack = {}

	function data_stack.set_data_handler(handler)
		data_hander = handler
	end

	function data_stack.undo()
		local index = index - 1
		if index >= 0 and index <= #stack then 
			index = index
			if index == 0 then 
				data_hander.init()
			else 
				data_hander.data = copy(stack[index])
			end
			print("undo", index)
		end
	end 

	function data_stack.redo()
		local index = index + 1
		if index >= 1 and index <= #stack then 
			index = index
			data_hander.data = copy(stack[index])
			print("redo", index)
		end
	end

	function data_stack.snapshoot()
		while(index >= 0 and #stack > index) do 
			table.remove(stack, #stack)
		end
		local new_data = copy(data_hander.data)
		table.insert(stack, new_data)
		index = #stack
		print("snapshoot", index)
	end

	return data_stack
end

return {create = create}