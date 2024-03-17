--------------------------------------------------------
-- 窗口标签列表
-------------------------------------------------------- 
---@type ly.game_editor.dep
local dep = require 'dep' 
local user_data = dep.common.user_data
local lib = dep.common.lib

---@class ly.game_editor.tab_item
---@field root string 根节点
---@field path string 路径
---@field name string 文件名
---@field fileType string 文件类型
---@field window table 窗口
local tb_tab_data 

---@param tabId string 
local function new(tabId)
	local api = {}		---@class ly.game_editor.tabs
	api.list = {}		---@type ly.game_editor.tab_item[]
	api.index = 0		---@type number 当前选中的tab

	--local save_key = tabId
	--local save_idx = tabId .. "_index"
	local function add_tab(path)
		local arr = lib.split(path, "/")
		local tb = {}
		tb.path = path
		tb.name = lib.get_file_name(path)
		tb.fileType = lib.get_file_ext(path)
		tb.root = arr[1]
		table.insert(api.list, tb)
	end

	local function init()
		-- local str = user_data.get(save_key, "")
		-- local array = lib.split(str, ";")
		-- for _, v in ipairs(array) do 
		-- 	add_tab(v)
		-- end
		-- api.index = user_data.get_number(save_idx, 0)
	end

	local function save()
		-- local tb = {}
		-- for i, v in ipairs(api.list) do 
		-- 	table.insert(tb, v.path)
		-- end
		-- user_data.set(save_key, table.concat(tb, ";"))
		-- user_data.set(save_idx, api.index)
		-- user_data.save()
	end

	function api.tostring()
	end
	function api.init_from_string()
	end

	function api.reset()
		api.list = {}
		api.index = 0
	end 

	---@param _tabs ly.game_editor.tabs
	function api.copy_to(_tabs)
		_tabs.list = {}
		for i, v in ipairs(api.list) do 
			_tabs.list[i] = v
		end
		_tabs.index = api.index
	end

	function api.close_others(tab)
		for i, v in ipairs(api.list) do 
			if v ~= tab then 
				table.remove(api.list, i)
			end
		end
		save()
	end

	function api.get_index()
		return api.index
	end

	function api.set_index(index)
		if index ~= api.index then 
			api.index = index
			save()
		end
	end

	---@return ly.game_editor.tab_item
	function api.find_by_path(path)
		for i, v in ipairs(api.list) do 
			if v.path == path then 
				return v
			end
		end
	end

	function api.open_tab(path)
	end

	function api.close_tab(tab)
		for i, v in ipairs(api.list) do 
			if v == tab then 
				table.remove(api.list, i)
				break
			end
		end
		save()
	end

	init()
	return api
end
return {new = new}