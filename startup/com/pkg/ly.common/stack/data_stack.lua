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
	local ref_save  -- 最近一次存档数据引用

	function data_stack.set_data_handler(handler)
		data_hander = handler
	end

	function data_stack.undo()
		local _index = index - 1
		if _index > 0 and _index <= #stack then 
			index = _index
			data_hander.data = copy(stack[index])
			data_hander.stack_version = index
			data_hander.isModify = data_stack.get_modify()
			print("undo", index)
		end
	end 

	function data_stack.redo()
		local _index = index + 1
		if _index >= 1 and _index <= #stack then 
			index = _index
			data_hander.data = copy(stack[index])
			data_hander.stack_version = index
			data_hander.isModify = data_stack.get_modify()
			print("redo", index)
		end
	end

	function data_stack.pop()
		if #stack > 0 then 
			table.remove(stack, #stack);
			if index > #stack then 
				index = #stack
			end
		end
	end

	---@param dirty boolean 数据是否有更改
	function data_stack.snapshoot(dirty)
		while(index >= 0 and #stack > index) do 
			table.remove(stack, #stack)
		end
		data_hander.data.cache = data_hander.data.cache or {}
		data_hander.data.cache.__dirty = dirty									-- 本次是否有数据变动
		data_hander.isModify = data_stack.get_modify()				
		local new_data = copy(data_hander.data)
		table.insert(stack, new_data)
		index = #stack
		data_hander.stack_version = index
		print("snapshoot", index)
	end

	---@return boolean 遍历所有堆栈，看数据是否有变化
	function data_stack.get_modify()
		if data_hander.data.cache.__dirty then 
			return true 
		end
		for i = index, 1, -1 do 
			local data = stack[i]
			if data and ref_save == data then 
				return false
			end
			if data and data.cache.__dirty then 
				return true 
			end
		end
		return false;
	end

	-- 当存档时
	function data_stack.on_save()
		ref_save = stack[index]
	end

	return data_stack
end

return {create = create}