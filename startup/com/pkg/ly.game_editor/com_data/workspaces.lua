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
	local api = {}			---@class ly.game_editor.tabs
	api.list = {}			---@type ly.game_editor.tab_item[]
	api.active_path = ""		---@type string 当前选中的tab
	api.dirty = false
	
	local function save()
		api.dirty = true
	end

	local function add_tab(path, insert_index)
		local arr = lib.split(path, "/")
		local tb = {}
		tb.path = path
		tb.name = lib.get_file_name(path)
		tb.fileType = lib.get_file_ext(path)
		tb.root = arr[1]
		if insert_index then 
			table.insert(api.list, insert_index, tb)
		else 
			table.insert(api.list, tb)
		end		
		return tb
	end

	function api.set_data(content)
		api.list = {}
		local array = lib.split(content or "", ";")
		for i = 2, #array  do 
			add_tab(array[i])
		end
		api.active_path = array[1]
	end

	function api.tostring()
		local tb = {api.active_path}
		for i, v in ipairs(api.list) do 
			table.insert(tb, v.path)
		end
		return table.concat(tb, ";")
	end

	function api.init_from_string()
	end

	function api.reset()
		api.list = {}
		api.active_path = nil
	end 

	---@param _tabs ly.game_editor.tabs
	function api.copy_to(_tabs)
		_tabs.list = {}
		for i, v in ipairs(api.list) do 
			_tabs.list[i] = v
		end
		_tabs.active_path = api.active_path
	end

	function api.close_others(tab)
		for i = #api.list, 1, -1 do 
			if api.list[i] ~= tab then 
				table.remove(api.list, i)
			end
		end
		save()
	end

	function api.get_active_path()
		return api.active_path
	end

	function api.set_active_path(path)
		if path ~= api.active_path then 
			api.active_path = path
			save()
		end
	end

	---@return ly.game_editor.tab_item
	function api.find_by_path(path)
		if not path then return end
		for i, v in ipairs(api.list) do 
			if v.path == path then 
				return v
			end
		end
	end

	function api.has_tab(path)
		return api.find_by_path(path) ~= nil
	end

	function api.open_tab(path, insert_index)
		local tab = api.find_by_path(path) 
		if not tab then 
			tab = add_tab(path, insert_index)
		end
		api.set_active_path(path)
	end

	---@param tab ly.game_editor.tab_item|string 
	function api.close_tab(tab)
		for i, v in ipairs(api.list) do 
			if v == tab or v.path == tab then 
				table.remove(api.list, i)
				if v.path == api.active_path then 
					if i > 1 then 
						api.active_path = api.list[i - 1].path
					elseif #api.list >= i then  
						api.active_path = api.list[i].path
					end
				end
				save()
				break
			end
		end
	end
	return api
end

---@return ly.game_editor.viewport
local function create_viewport(id)
	local viewport = {} 			---@class ly.game_editor.viewport
	viewport.tabs = create_tab()   	---@type ly.game_editor.tabs
	viewport.id = id; 				---@type number 在space下的唯一id
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
	space.active_viewport = nil  	---@type ly.game_editor.viewport
	space.lock = false				---@type boolean 是否锁定

	function space.init()
		space.view = space.create_viewport(0, 1)
	end

	function space.get_data()
		local tb_save = {view = space.view.get_data(), next_id = space.next_id, lock = space.lock}
		return tb_save
	end

	function space.set_data(tb_save)
		space.next_id = tb_save.next_id
		space.lock = tb_save.lock
		space.view = create_viewport() 
		space.view.set_data(tb_save.view)
		space.active_viewport = space.find_valid_child_viewport(space.view)
	end

	function space.is_lock() return space.lock end 
	function space.set_lock(v) space.lock = v end

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
	---@return ly.game_editor.viewport
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

		if space.active_viewport == view then 
			space.active_viewport = view1
		end
		return view
	end

	-- 查找窗口
	---@return ly.game_editor.viewport
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

	-- 查找视口的父视口
	---@return ly.game_editor.viewport
	function space.find_parent_viewport(viewport_id) 
		---@param view ly.game_editor.viewport
		local function find(view)
			if view.type == 0 then return end
			for i, v in ipairs(view.children) do 
				if v.id == viewport_id then 
					return view
				end 
				local ret = find(v)
				if ret then 
					return ret
				end
			end
		end
		return find(space.view)
	end

	--- 查找指定视口下第一个真实显示的视口
	function space.find_valid_child_viewport(view)
		---@param child ly.game_editor.viewport
		local function find(child)
			if child.type == 0 then return child end 
			return find(child.children[1]) or find(child.children[2])
		end
		return find(view)
	end

	function space.set_active_viewport(viewport_id)
		if space.active_viewport and space.active_viewport.id == viewport_id then 
			return
		end
		space.active_viewport = space.find_viewport_by_id(viewport_id)
	end

	function space.get_active_viewport()
		return space.active_viewport or space.view
	end

	-- 移除视口
	---@param viewport_id number 视口id
	function space.remove_viewport(viewport_id)
		---@param from ly.game_editor.viewport
		---@param to ly.game_editor.viewport
		local function merge(from, to, other)
			if from.type == 0 then 
				from.tabs.copy_to(to.tabs)
				to.type = 0
			else 
				to.type = from.type
				to.tabs = from.tabs
				to.children = from.children
			end
			if space.active_viewport == from or space.active_viewport == other then 
				space.active_viewport = to
			end
		end 
		---@param view ly.game_editor.viewport
		local function remove(view)
			if view.type == 0 then return end
			local left = view.children[1]
			local right = view.children[2]
			if left.id == viewport_id then 
				return merge(right, view, left)
			elseif right.id == viewport_id then
				return merge(left, view, right)
			end 
			remove(left)
			remove(right)
		end
		remove(space.view)
	end

	---@param view ly.game_editor.viewport
	function space.clone_tab(view, path)
		local parent = space.find_parent_viewport(view.id)
		if parent then 
			local child1 = parent.children[1]
			local child2 = parent.children[2]
			if child1 == view then 
				local v = space.find_valid_child_viewport(child2)
				if v then 
					v.tabs.open_tab(path)
				end
			else 
				local v = space.find_valid_child_viewport(child1)
				if v then 
					v.tabs.open_tab(path)
				end
			end
		else
			parent = space.split(view.id, 2)
			parent.children[2].tabs.open_tab(path)
		end
	end

	return space
end


---@param editor ly.game_editor.editor
---@return ly.game_editor.workspaces
local function new(editor)
	local api = {} 		---@class ly.game_editor.workspaces
	api.works = {} 		---@type ly.game_editor.space[]
	api.index = 1; 		---@type number 当前选中的work

	local file_path = string.format("%s/%s_workspace.ant", path_def.cache_root, editor.tbParams.module_name) 

	-- 初始化
	local function init()
		local f<close> = io.open(file_path, 'r')
		if f then 
			local content = f:read "a"
			local tb_save = dep.datalist.parse(content) or {}
			for i, v in ipairs(tb_save.items) do 
				local space = create_space()
				space.set_data(v)
				table.insert(api.works, space)
			end
			api.index = tb_save.index or 1
		end 

		if #api.works == 0 then
			api.works = {}
			api.add()
		end
	end 

	-- 保存
	function api.save()
		dep.bfs.create_directories(path_def.cache_root)
		local tb_save = {items = {}, index = api.index}
		for i, v in ipairs(api.works) do 
			tb_save.items[i] = v.get_data()
		end
		local content = dep.serialize.stringify(tb_save)
		local f<close> = assert(io.open(file_path, "w"))
    	f:write(content)
	end

	function api.exit()
		api.save()
	end

	function api.add()
		local space = create_space()
		space.init()
		table.insert(api.works, space)
		api.index = #api.works
	end

	function api.current_space()
		return api.works[api.index]
	end

	function api.set_current_space(index)
		if index ~= api.index then 
			api.index = index
		end
	end

	function api.close_self(index, space)
		table.remove(api.works, index)
	end 

	function api.close_others(index, space)
		for i, v in ipairs(api.works) do 
			if v == space then 
				api.index = i
			elseif not v.lock then 
				table.remove(api.works, i)
			end
		end
	end

	init()
	return api
end

return {new = new}