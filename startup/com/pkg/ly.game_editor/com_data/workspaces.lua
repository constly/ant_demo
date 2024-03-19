--------------------------------------------------------
-- 工作空间
-- 一个工作空间下有多个viewport, 一个viewport对应一个tabs
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep' 
local lib = dep.common.lib
local path_def = dep.common.path_def

---@class ly.game_editor.tab_item
---@field root string 根节点
---@field path string 路径
---@field name string 文件名
---@field fileType string 文件类型
local tb_tab_data 


---@param content string tab内容
local function create_tab(content)
	local api = {}		---@class ly.game_editor.tabs
	api.list = {}		---@type ly.game_editor.tab_item[]
	api.index = 0		---@type number 当前选中的tab
	api.dirty = false

	
	local function save()
		api.dirty = true
	end

	local function add_tab(path)
		local arr = lib.split(path, "/")
		local tb = {}
		tb.path = path
		tb.name = lib.get_file_name(path)
		tb.fileType = lib.get_file_ext(path)
		tb.root = arr[1]
		table.insert(api.list, tb)
	end

	function api.set_data(content)
		api.list = {}
		local array = lib.split(content or "", ";")
		for i = 2, #array  do 
			add_tab(array[i])
		end
		api.index = tonumber(array[1])
	end

	function api.tostring()
		local tb = {api.index}
		for i, v in ipairs(api.list) do 
			table.insert(tb, v.path)
		end
		return table.concat(tb, ";")
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

	return api
end

---@return ly.game_editor.viewport
local function create_viewport(id)
	local viewport = {} 			---@class ly.game_editor.viewport
	viewport.tabs = create_tab()   	---@type ly.game_editor.tabs
	viewport.id = id; 				---@type number 在flow下的唯一id
	viewport.children = {};			---@type ly.game_editor.viewport[] 子窗口列表
	viewport.type = 0 				---@type number 视口类型: 0-全屏 1-左右分割 2-上下分割
	viewport.size_rate = 1			---@type number 所占百分比大小		

	function viewport.get_data()
		local tb_save = {}
		tb_save.tabs = viewport.tabs.tostring()
		tb_save.id = viewport.id
		tb_save.type = viewport.type
		tb_save.size_rate = viewport.size_rate
		tb_save.children = {}
		for i, v in ipairs(viewport.children) do 
			tb_save.children[i] = v.get_data()
		end
		return tb_save
	end 
	function viewport.set_data(tb_save)
		viewport.tabs.set_data(tb_save.tabs)
		viewport.id = tb_save.id
		viewport.type = tb_save.type
		viewport.size_rate = tb_save.size_rate
		for i, v in ipairs(tb_save.children) do 
			local child = create_viewport(0)
			child.set_data(v)
			viewport.children[i] = child
		end
	end
	return viewport
end

---@return ly.game_editor.space
local function create_space()
	local space = {} 				---@class ly.game_editor.space
	space.view = {} 				---@type ly.game_editor.viewport
	space.next_id = 0

	function space.init()
		space.view = space.create_viewport(0, 1)
	end

	function space.get_data()
		local tb_save = {view = space.view.get_data(), next_id = space.next_id}
		return tb_save
	end

	function space.set_data(tb_save)
		space.next_id = tb_save.next_id
		space.view = create_viewport() 
		space.view.set_data(tb_save.view)
	end

	function space.create_viewport(type, size_rate)
		space.next_id = space.next_id + 1
		local view = create_viewport(space.next_id)
		view.type = type
		view.size_rate = size_rate
		return view
	end

	-- 分割viewport
	---@param viewport_id number 视口id
	---@param type number 说明:1-水平分割;2-竖直分割
	function space.split(viewport_id, type)
		local view = space.find_viewport_by_id(viewport_id)
		if not view then return end

		local view1 = space.create_viewport(0, 0.5)
		local view2 = space.create_viewport(0, 0.5)
		view.type = type
		view.tabs.copy_to(view1.tabs)
		view.tabs.reset()
		view.children[1] = view1
		view.children[2] = view2
	end

	function space.find_viewport_by_id(id)
		---@param views ly.game_editor.viewport
		local function find(view)
			if view.id == id then 
				return view
			end
			for i, v in ipairs(view.children) do 
				local ret = find(v)
				if ret then
					return ret; 
				end
			end
		end
		return find(space.view)
	end

	return space
end


---@param editor ly.game_editor.editor
---@return ly.game_editor.workspaces
local function new(editor)
	local api = {} 		---@class ly.game_editor.workspaces
	api.items = {} 		---@type ly.game_editor.space[]
	api.index = 1; 		---@type number 当前选中的space

	local file_path = string.format("%s/%s_workspace.ant", path_def.cache_root, editor.tbParams.module_name) 

	-- 初始化
	local function init()
		-- local f<close> = io.open(file_path, 'r')
		-- if f then 
		-- 	local content = f:read "a"
		-- 	local tb_save = dep.datalist.parse(content) or {}
		-- 	for i, v in ipairs(tb_save.items) do 
		-- 		local space = create_space()
		-- 		space.set_data(v)
		-- 		table.insert(api.items, v)
		-- 	end
		-- 	api.index = tb_save.index or 1
		-- end 

		if #api.items == 0 then
			api.items = {}
			api.add()
			api.save()
		end
	end 

	-- 保存
	function api.save()
		local tb_save = {items = {}, index = api.index}
		for i, v in ipairs(api.items) do 
			tb_save.items[i] = v.get_data()
		end
		local content = dep.serialize.stringify(tb_save)
		local f<close> = assert(io.open(file_path, "w"))
    	f:write(content)
	end

	function api.add()
		local space = create_space()
		space.init()
		space.split(1, 1)
		space.split(3, 2)
		space.split(4, 2)
		space.split(5, 1)
		space.split(9, 2)
		space.split(8, 1)
		table.insert(api.items, space)
	end

	function api.current_space()
		return api.items[api.index]
	end

	function api.set_current_space(index)
		api.index = index
	end

	init()
	return api
end

return {new = new}