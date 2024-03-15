--------------------------------------------------------
-- 传送门数据
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep' 
local user_data = dep.common.user_data
local lib = dep.common.lib

---@param editor ly.game_editor.editor
local function create(editor)
	local api = {} 		---@type ly.game_editor.portal
	api.pages = {}		---@type table[] 页面列表
	api.cur_page = 0  	---@type number 当前选中的页面索引

	local max_page = 6
	local save_key = editor.tbParams.module_name  .. "_portal_"
	local function load()
		for i = 1, max_page do 
			local str = user_data.get(save_key .. i, "")
			local array = lib.split(str, ";")
			api.pages[i] = array
		end
		api.cur_page = user_data.get_number(save_key .. "cur", 0)
	end

	--- 保存数据
	local function save()
		for i = 1, max_page do 
			local str = table.concat(api.pages[i], ";") 
			user_data.set(save_key .. i, str)
		end
		user_data.set(save_key .. "cur", api.cur_page)
		user_data.save()
	end
	
	---@param path string 文件路径
	function api.add(path)
		local list = api.pages[api.cur_page]
		if not list then return end 
		for _, v in ipairs(list) do 
			if v == path then 
				return 
			end 
		end
		table.insert(list, path)
		save()
	end

	---@param path string 文件路径
	function api.remove(path)
		local list = api.pages[api.cur_page]
		if not list then return end 
		for i, v in ipairs(list) do 
			if v == path then 
				table.remove(list, i)
				break
			end 
		end
		save()
	end

	--- 设置当前激活的页面
	function api.set_page(idx)
		if idx ~= api.cur_page then 
			api.cur_page = idx
			save()
		end
	end

	load()
	return api
end 

return {create = create}