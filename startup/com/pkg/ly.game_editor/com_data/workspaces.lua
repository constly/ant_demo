--------------------------------------------------------
-- 工作空间
-- 一个工作空间下有多个viewport, 一个viewport对应一个tabs
--------------------------------------------------------
local tabs = require 'com_data.tabs'

---@alias ly.game_editor.viewport.type
---| "0" # 全屏0
---| "1" # 上面1
---| "2" # 下面2
---| "3" # 左边3
---| "4" # 右边4

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
	local space = {} 			---@class ly.game_editor.space
	space.views = {} 			---@type ly.game_editor.viewport[]
	space.next_id = 0


	function space.init()
		local view = space.create_viewport(0, 1)
		space.views[1] = view
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
	---@param is_horizontal boolean 是否水平分割
	function space.split(viewport_id, is_horizontal)
		local view = space.find_viewport_by_id(viewport_id)
		if not view then return end

		local view1 = space.create_viewport()
		local view2 = space.create_viewport()
		if is_horizontal then 	-- 左右分割
			view1 = space.create_viewport(3, 0.5)
			view2 = space.create_viewport(4, 0.5)
		else 					-- 上下分割
			view1 = space.create_viewport(1, 0.5)
			view2 = space.create_viewport(2, 0.5)
		end
		view.tabs.copy_to(view1.tabs)
		view.tabs.reset()
		view.children[1] = view1
		view.children[2] = view2
	end

	---@param parentId number 父视口id
	function space.add_viewport(parentId)
		local parent = space.find_viewport_by_id(parentId)
		if not parent then return end 
		space.next_id = space.next_id + 1
		local view = create_viewport()
		view.id = space.next_id
		table.insert(parent.children, view)
	end

	function space.find_viewport_by_id(id)
		---@param views ly.game_editor.viewport[]
		local function find(views)
			for i, v in ipairs(views) do 
				if v.id == id then 
					return v 
				else 
					local ret = find(v.children)
					if ret then
						return ret; 
					end
				end
			end
		end
		return find(space.views)
	end

	return space
end


---@param editor ly.game_editor.editor
---@return ly.game_editor.workspaces
local function new(editor)
	local api = {} ---@class ly.game_editor.workspaces
	api.items = {} ---@type ly.game_editor.space[]

	function api.init()
		local space = create_space()
		space.init()

		space.split(1, true)
		space.split(3, false)

		table.insert(api.items, space)
	end

	function api.current_space()

	end

	function api.set_current_space()
	
	end

	api.init()
	return api
end

return {new = new}