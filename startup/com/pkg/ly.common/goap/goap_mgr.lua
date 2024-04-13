--------------------------------------------------------
-- goap mgr
--------------------------------------------------------

---@class goap.action.param 
---@field type string 数据类型
---@field key string  数据key
---@field desc strng 数据描述
---@field default any 默认值

---@class goap.action 
---@field id string 
---@field name string 
---@field desc string 
---@field owner string
---@field params goap.action.param[]

local function new()
	---@class goap_mgr
	---@field actoins goap.action[] 
	local goap_mgr = {}
	goap_mgr.actoins = {} 

	function goap_mgr.new_action(id, name, desc)
		---@type goap.action
		local action = {}
		action.id = id 
		action.name = name 
		action.desc = desc
		action.params = {}

		function action.def_param(type, id, desc, default)
			local param = {}
			param.type = type
			param.key = id 
			param.desc = desc 
			param.default = default
			table.insert(action.params, param)
			return action
		end

		function action.set_preview(str)
			action.preview = str
			return action
		end

		function action.set_owner(name)
			action.owner = name
			return action
		end 

		function action.reg_api(callback)
			action.get_api = callback
			return action
		end

		table.insert(goap_mgr.actoins, action)
		return action
	end	

	function goap_mgr.get_all_actions()
		local all = {}

		local function get_region(name)
			for i, v in ipairs(all) do 
				if v.name == name then 
					return v
				end
			end
			local tb = {name = name, list = {}}
			table.insert(all, tb)
			return tb
		end 

		for i, v in ipairs(goap_mgr.actoins) do 
			local region = get_region( v.owner or "default" )
			table.insert(region.list, v)
		end 
		return all;
	end 

	
	---@return goap.api
	function goap_mgr.new_api(id)
		---@type goap.api
		---@field actionId string
		local api = {}
		api.actionId = id
		--- 初始化时
		function api.on_init(data)
		end
		--- 当action开始时
		function api.on_begin()
		end 
		--- 当action结束时
		function api.on_end()
		end 
		--- 每帧更新
		function api.on_update(delta_time)
		end
		--- action是否已经完成
		function api.is_complete()
		end
		-- 转换为字符串
		function api.to_string()
		end 
		-- 序列化
		function api.serialize()
		end 
		-- 反序列化
		function api.deserialize(data)
		end
		return api
	end

	return goap_mgr
end


return {new = new}