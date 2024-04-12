--------------------------------------------------------
-- goap 数据处理
--------------------------------------------------------
---@type ly.game_editor.dep
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
---@field data ly.game_editor.goap.node.body.section 身体数据
---@field type string 数据类型


---@class ly.game_editor.goap.node 节点
---@field id number 节点id
---@field name string 节点名字
---@field desc string 节点描述
---@field disable boolean 是否禁用
---@field tags string[] tag列表
---@field conditions ly.game_editor.goap.condition[]
---@field effects ly.game_editor.goap.effect[]
---@field body ly.game_editor.goap.node.body

---@class ly.game_editor.goap.setting goap配置
---@field tag string tag配置表
---@field attr string attr配置表

---@class ly.game_editor.goap.data
---@field nodes ly.game_editor.goap.node[] 节点列表
---@field settings ly.game_editor.goap.setting 配置表
---@field next_id number 下个节点id

---@param editor ly.game_editor.editor
---@param stack common_data_stack
local function new(editor, stack)
	---@class ly.game_editor.goap.handler
	---@field data ly.game_editor.goap.data
	---@field attr_handler ly.game_editor.attr.handler
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	---@type ly.game_editor.goap.body.fsm
	api.body_fsm = require 'windows.goap.body_type_fsm'.new(editor, stack, api)
	---@type ly.game_editor.goap.body.lines
	api.body_lines = require 'windows.goap.body_type_lines'.new(editor, stack, api)
	---@type ly.game_editor.goap.body.sections
	api.body_sections = require 'windows.goap.body_type_sections'.new(editor, stack, api)

	api.attr_handler = require 'windows.attr.attr_handler'.new()

	---@param data ly.game_editor.tag.data
	function api.set_data(data)
		if not data or type(data) ~= "table" or not data.nodes then 
			data = {nodes = {}}
		end 
		data.next_id = data.next_id or 0
		data.settings = data.settings or {}
		api.data = data
		api.cache = api.cache or {}
		if #data.nodes > 0 then 
			api.set_selected(data.nodes[1].name)
		end 
		api.modify_setting(data.settings)
	end

	function api.modify_setting(settings)
		api.data.settings = settings

		if settings.attr then 
			local data = dep.common.file.load_datalist(settings.attr)
			api.attr_handler.set_data(data)
		else 
			api.attr_handler.set_data(nil)
		end
	end

	function api.to_string()
		local cache = api.data.cache
		api.data.cache = nil
		local content = dep.common.datalist.serialize(api.data)
		api.data.cache = cache
		return content
	end

	---@return ly.game_editor.goap.node
	function api.add_node(name)
		api.data.next_id = api.data.next_id + 1
		---@type ly.game_editor.goap.node
		local node = {}
		node.tags = {}
		node.conditions = {"and", {}}
		node.effects = {{}}
		node.body = {type = "lines"}
		node.name = name
		node.desc = ""
		node.id = api.data.next_id
		api.body_lines.init(node)
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

	function api.add_effect(node, idx)
		---@type ly.game_editor.goap.effect
		local effect = {}
		if idx then 
			table.insert(node.effects, idx, effect)
		else 
			table.insert(node.effects, effect)
		end
		return effect
	end

	--------------------------------------------------------
	--- 节点条件相关
	--------------------------------------------------------
	function api.delete_condition(node, data)
		local parent = api.get_condition_parent(node, data)
		if parent then 
			if parent == node.conditions and #parent <= 2 then 
				return
			end 
			for i, v in ipairs(parent) do 
				if v == data then 
					table.remove(parent, i)
				end
			end
			if #parent <= 1 then 
				api.delete_condition(node, parent)
			elseif #parent == 2 then
				local p1 = api.get_condition_parent(node, parent)
				if p1 then 
					for i, v in ipairs(p1) do 
						if v == parent then 
							p1[i] = parent[2]
						end
					end 
				end
			end 
		end
	end 

	function api.move_condition(node, data, delta)
		local parent = api.get_condition_parent(node, data)
		if parent and #parent > 2 then 
			for i, v in ipairs(parent) do 
				if v == data then 
					table.remove(parent, i)
					local idx = i + delta
					if idx >= 0 and idx <= #parent then
						table.insert(parent, idx, data)
					else 
						table.insert(parent, data)
					end
					return
				end 
			end 
		end
	end

	---@param node ly.game_editor.goap.node
	function api.get_condition_parent(node, data)
		local function find(arr)
			if type(arr) == "table" then
				for i, v in ipairs(arr) do 
					if v == data then 
						return arr
					else
						local f = find(v)
						if f then 
							return f
						end 
					end
				end 
			end
		end 
		return find(node.conditions) 
	end 

	--------------------------------------------------------
	--- 节点选中相关
	--------------------------------------------------------
	local function get_cache(node_id)
		local cache = api.data.cache or {}
		api.data.cache = cache
		cache.selected = cache.selected or nil
		cache.nodes = cache.nodes or {}
		if node_id then 
			local c = cache.nodes[node_id] or {type = "none", list = {}, body = {}}
			cache.nodes[node_id] = c
			return c
		else
			return cache 
		end
	end

	--- 得到身体的缓存
	function api.get_body_cache(node_id)
		local cache = get_cache(node_id)
		return cache.body
	end

	function api.set_selected(name)
		local cache = get_cache()
		if cache.selected ~= name then 
			cache.selected = name
			return true
		end
	end

	function api.get_selected()
		local cache = get_cache()
		return cache.selected
	end

	---@return ly.game_editor.goap.node
	function api.get_selected_node()
		local name = api.get_selected()
		return name and api.find_node(name)
	end

	--------------------------------------------------------
	--- 节点内部条目选中相关
	--------------------------------------------------------
	function api.set_selected_item(node_id, type, id)
		local cache = get_cache(node_id)
		if cache.type ~= type or cache.list[1] ~= id then
			cache.type = type
			cache.list = id and {id} or {}
			return true
		end 
	end
	
	function api.add_selected_item(node_id, type, id)
		local cache = get_cache(node_id)
		if cache.type == type then 
			for i, v in ipairs(cache.list) do 
				if v == id then 
					return 
				end
			end
			table.insert(cache.list, id)
		else 
			api.set_selected_item(type, id)
		end
	end

	function api.is_item_selected(node_id, type, id)
		local cache = get_cache(node_id)
		if cache.type == type then 
			for i, v in ipairs(cache.list) do 
				if v == id then 
					return true 
				end
			end
		end 
		return false
	end

	function api.get_first_item_selected(node_id)
		local cache = get_cache(node_id)
		return cache.type, cache.list[1]
	end

	function api.has_item_selected(node_id)
		local cache = get_cache(node_id)
		return cache.type and #cache.list > 0
	end

	--------------------------------------------------------
	--- body相关
	--------------------------------------------------------
	---@param node ly.game_editor.goap.node
	function api.set_body_type(node, type)
		if node.body.type == type then 
			return 
		end 
		node.body.type = type
		if type == "lines" then 
			api.body_lines.init(node)
		elseif type == "sections" then 
			api.body_sections.init(node)
		elseif type == "fsm" then 
			api.body_fsm.init(node)
		else 
			error("invalid type " .. type)
		end 
	end 

	return api
end

return {new = new}