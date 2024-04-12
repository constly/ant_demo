--------------------------------------------------------
-- goap mgr
--------------------------------------------------------

local goap_mgr = {}
goap_mgr.actoins = {}
function goap_mgr.new_action(id, name, desc)
	local action = {}
	action.id = id 
	action.name = name 
	action.desc = desc
	action.params = {}

	function action.def_param(type, id, desc, default)
		local param = {}
		param.type = type
		param.id = id 
		param.desc = desc 
		param.default = default
		table.insert(action.params, param)
		return action
	end

	function action.set_preview(str)
		action.preview = str
		return action
	end

	function action.set_owner_region(name)
		action.owner_region = name
		return action
	end 

	function action.reg_api(callback)
		action.get_api = callback
		return action
	end

	table.insert(goap_mgr.actoins, action)
	return action
end

---@return goap.action
function goap_mgr.new_api(id)
	---@class goap.action
	local action = {}
	action.actionId = id
	--- 初始化时
	function action.on_init(data)
	end
	--- 当action开始时
	function action.on_begin()
	end 
	--- 当action结束时
	function action.on_end()
	end 
	--- 每帧更新
	function action.on_update(delta_time)
	end
	--- action是否已经完成
	function action.is_complete()
	end
	-- 转换为字符串
	function action.to_string()
	end 
	-- 序列化
	function action.serialize()
	end 
	-- 反序列化
	function action.deserialize(data)
	end
	return action
end


do 
	--------------------------------------------------------
	-- 等待一段时间 
	--------------------------------------------------------
	local action_id = "action_wait_time"
	goap_mgr.new_action(action_id, "等待一段时间")
	.def_param("number", "time", "时间(秒)", "0")
	.set_preview("等待{{time}}秒")
	.set_owner_region({"global"})
	.reg_api(function()
		local api = goap_mgr.new_api(action_id)
		local time = 0;
		local max_time = 0;
		function api.on_init(data)
			max_time = tonumber(data.time) or 0
		end
		function api.on_begin()
			time = 0
		end
		function api.on_update(delta_time)
			time = time + delta_time
		end
		function api.is_complete()
			return max_time >= 0 and time >= max_time
		end
		function api.to_string() 
			return string.format("等待中,剩余:%d秒", max_time - time)
		end
		function api.serialize()
			local save = {time = time}
			return save
		end
		function api.deserialize(save)
			time = save.time
		end
		return api
	end)
end 

do 
	--------------------------------------------------------
	-- 等待点击屏幕 
	--------------------------------------------------------
	local action_id = "action_wait_input"
	goap_mgr.new_action(action_id, "等待输入")
	.set_preview("等待输入")
	.set_owner_region({"global"})
	.reg_api(function()
		local api = goap_mgr.new_api(action_id)
		local complete = false
		function api.on_update()
			if false then 
				complete = true
			end
		end
		function api.is_complete()
			return complete
		end
		return api
	end)
end 

do 
	--------------------------------------------------------
	-- 输出 
	--------------------------------------------------------
	local action_id = "action_print"
	goap_mgr.new_action(action_id, "打印消息")
	.def_param("string", "msg", "内容", "")
	.set_preview("输出:{{msg}}")
	.set_owner_region({"global"})
	.reg_api(function()
		local api = goap_mgr.new_api(action_id)
		local msg 
		function api.on_init(data)
			msg = data.msg
		end
		function api.on_begin()
			print("打印: ", msg)
		end
		function api.is_complete()
			return true
		end
		return api
	end)
end 

do
	--[[
	节点应该有多种类型:
		1. 全局静态节点: 比如wait_time, print
		2. 对象节点: 如npc对象, 队伍对象，社团对象等等
	--]]

	--------------------------------------------------------
	-- 挖矿 
	--------------------------------------------------------
	local action_id = "action_mining"
	goap_mgr.new_action(action_id, "挖矿")
	.def_param("int", "name", "名字", "0")
	.def_param("string", "desc", "描述", "")
	.def_param("number", "speed", "产出", "")
	.set_owner_region({"npc"})
	-- 是否还应该有input, output, as, 以及所属对象
	.reg_api(function()
		local api = goap_mgr.new_api(action_id)
		function api.on_begin()
		end 

		function api.on_end()
		end 

		function api.on_update(delta_time)
		end
		
		function api.is_complete()
			return api.complete;
		end

		return api
	end)
end 

return goap_mgr