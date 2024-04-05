--------------------------------------------------------
-- tag 数据处理
--------------------------------------------------------
local dep = require 'dep'
local lib = dep.common.lib

---@class ly.game_editor.tag.data
---@field name string 
---@field desc string 
---@field children ly.game_editor.tag.data[]

local function new()
	---@class ly.game_editor.tag.handler
	---@field data ly.game_editor.tag.data
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	---@param data ly.game_editor.tag.data
	function api.set_data(data)
		if not data or type(data) ~= "table" or not data.children then 
			data = {}
			data.name = "root"
			data.desc = ""
			data.children = {}
		end 
		api.data = data
	end

	---@return ly.game_editor.tag.data 通过名字查找节点
	function api.find_by_name(name)
		---@param node ly.game_editor.tag.data
		local function find(node)
			if node.name == name then 
				return node
			end 
			for i, v in ipairs(node.children) do 
				local ret = find(v)
				if ret then 
					return ret
				end 
			end
		end
		return find(api.data)
	end

	---@return boolean 名字是否已经存在
	function api.is_tag_exist(name)
		return api.find_by_name(name) ~= nil
	end

	---@return ly.game_editor.tag.data  添加tag
	---@param parent ly.game_editor.tag.data 父节点
	function api.add_tag(name, parent, pos)
		local ret = api.find_by_name(name) 
		if ret then return ret end 

		parent = parent or api.data
		local node = {}
		node.name = name
		node.desc = ""
		node.children = {}
		if not pos or pos > #parent.children then 
			table.insert(parent.children, node)
		else 
			table.insert(parent.children, pos, node)
		end
		return node
	end

	---@return ly.game_editor.tag.data 移除节点
	function api.remove_tag(name)
		---@param node ly.game_editor.tag.data
		local function remove(node)
			for i, v in ipairs(node.children) do 
				if v.name == name then
					return table.remove(node.children, i)
				end
			end
		end
		return remove(api.data)
	end

	return api;
end

return {new = new}