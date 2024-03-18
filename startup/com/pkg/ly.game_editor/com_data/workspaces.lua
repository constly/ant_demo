--------------------------------------------------------
-- 工作空间
-- 一个工作空间下有多个viewport, 一个viewport对应一个tabs
--------------------------------------------------------
local tabs = require 'com_data.tabs'

---@alias ly.game_editor.viewport.type
---| "0" # 全屏0
---| "1" # 左右分割
---| "2" # 上下分割

---@return ly.game_editor.viewport
local function create_viewport(id)
	local viewport = {} 			---@class ly.game_editor.viewport
	viewport.tabs = tabs.new()   	---@type ly.game_editor.tabs
	viewport.id = id; 				---@type number 在flow下的唯一id
	viewport.children = {};			---@type ly.game_editor.viewport[] 子窗口列表
	viewport.type = 0 				---@type ly.game_editor.viewport.type 视口类型
	viewport.size_rate = 1			---@type number 所占百分比大小		

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

	function api.init()
		api.items = {}
		api.add()
	end

	function api.add()
		local space = create_space()
		space.init()
		space.split(1, 1)
		space.split(3, 2)
		space.split(4, 2)
		space.split(5, 1)
		table.insert(api.items, space)
	end

	function api.current_space()
		return api.items[api.index]
	end

	function api.set_current_space(index)
		api.index = index
	end

	api.init()
	return api
end

return {new = new}