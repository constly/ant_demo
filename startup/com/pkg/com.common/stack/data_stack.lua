---------------------------------------------------------------------------
--- 数据堆栈处理，主要用于支持编辑器的撤销/回退功能
---------------------------------------------------------------------------

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
	---@class common_data_stack  数据堆栈处理器(用于支持 撤销/回退)
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

	---@param dirty boolean 数据是否有更改
	function data_stack.snapshoot(dirty)
		while(index >= 0 and #stack > index) do 
			table.remove(stack, #stack)
		end
		data_hander.data.__dirty = dirty									-- 本次是否有数据变动
		data_hander.data.__isModify = data_stack.get_modify()				-- 遍历所有堆栈，看数据是否有变化
		local new_data = copy(data_hander.data)
		table.insert(stack, new_data)
		index = #stack
		print("snapshoot", index)
	end

	function data_stack.get_modify()
		if data_hander.data.__dirty then 
			return true 
		end
		for i = 1,  index do 
			local data = stack[i]
			if data and data.__dirty then 
				return true 
			end
		end
		return false;
	end

	return data_stack
end

return {create = create}