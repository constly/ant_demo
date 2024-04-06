--------------------------------------------------------
-- goap 数据处理
--------------------------------------------------------
local dep = require 'dep'
local lib = dep.common.lib

---@class ly.game_editor.goap.condition 条件
---@field region string 作用域
---@field id string id 
---@field opt string 操作类型
---@field value any 操作值


---@class ly.game_editor.goap.effect 影响
---@field region string 作用域
---@field id string id 
---@field opt string 操作类型
---@field value any 操作值


---@class ly.game_editor.goap.node.body.line 
---@field actionId string 
---@field params map<string, any> 参数列表
---@field disable boolean 是否禁用


---@class ly.game_editor.goap.node.body.section 子段落
---@field lines ly.game_editor.goap.node.body.line[]


---@class ly.game_editor.goap.node.body 身体
---@field sections ly.game_editor.goap.node.body.section[] 段落列表
---@field type string 数据类型


---@class ly.game_editor.goap.node 节点
---@field name string 节点名字
---@field desc string 节点描述
---@field disable boolean 是否禁用
---@field tags string[] tag列表
---@field conditions ly.game_editor.goap.condition[]
---@field effects ly.game_editor.goap.effect[]
---@field body ly.game_editor.goap.node.body


---@class ly.game_editor.goap.data
---@field nodes ly.game_editor.goap.node[] 节点列表


local function new()
	---@class ly.game_editor.goap.handler
	---@field data ly.game_editor.goap.data
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	---@param data ly.game_editor.tag.data
	function api.set_data(data)
		if not data or type(data) ~= "table" or not data.nodes then 
			data = {nodes = {}}
		end 
		api.data = data
		api.cache = api.cache or {}
	end

	function api.to_string()
		local cache = api.data.cache
		api.data.cache = nil
		local content = dep.serialize.stringify(api.data)
		api.data.cache = cache
		return content
	end

	---@return ly.game_editor.goap.node
	function api.add_node(name)
		---@type ly.game_editor.goap.node
		local node = {}
		node.tags = {}
		node.conditions = {}
		node.effects = {}
		node.body = {}
		node.name = name
		node.desc = ""
		node.disable = false
		table.insert(api.data.nodes, node)
		return node
	end

	---@return ly.game_editor.goap.node
	function api.clone_node(name)
		for i, v in ipairs(api.data.nodes) do 
			if v.name == name then 
				local node = lib.copy(v)
				node.name = api.next_name(node.name)
				table.insert(api.data.nodes, i + 1, node)
				return node
			end
		end
	end

	---@return ly.game_editor.goap.node
	function api.remove_node(name)
		for i, v in ipairs(api.data.nodes) do 
			if v.name == name then 
				return table.remove(api.data.nodes, i)
			end
		end
	end

	---@return ly.game_editor.goap.node|nil
	function api.find_node(name)
		for i, v in ipairs(api.data.nodes) do 
			if v.name == name then 
				return v, i
			end
		end
	end

	function api.next_name(name)
		if not api.find_node(name) then return name end 
		for i = 1, 999 do 
			local temp = name .. i
			if not api.find_node(temp) then return temp end
		end 
		return name
	end

	function api.set_selected(name)
		local cache = api.data.cache or {}
		api.data.cache = cache
		if cache.selected ~= name then 
			cache.selected = name
			return true
		end
	end

	function api.get_selected()
		local cache = api.data.cache 
		return cache and cache.selected
	end


	return api
end

return {new = new}