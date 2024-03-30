--------------------------------------------------------
-- 窗口管理
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local ImGui = dep.ImGui
local lib = dep.common.lib

---@class ly.game_editor.wnd_base
---@field is_dirty function 是否有修改
---@field update function 更新
---@field close function 关闭窗口，释放资源
---@field save function 保存数据
---@field reload function 重新加载文件
---@field handleKeyEvent function 处理键盘事件
local tb_wnd_base = {}

---@param editor ly.game_editor.editor
local function new(editor)
	local api = {}  	---@class ly.game_editor.wnd_mgr
	api.windows = {}	---@type map<string, ly.game_editor.wnd_base> 所有窗口

	---@param delta_time number 更新间隔,单位秒
	---@param view ly.game_editor.viewport  要渲染的窗口自身
	---@param is_active boolean 窗口是否激活
	function api.render(delta_time, view, is_active)
		local path = view.tabs.get_active_path()
		if not view.tabs.has_tab(path) then return end
		local window = api.get_or_create_window(path)
		if window then 
			window.update(delta_time);
			if is_active then 
				window.handleKeyEvent()
			end
		else 
			ImGui.Text("功能未实现: " .. path)
		end		
	end

	---@return ly.game_editor.wnd_base
	function api.get_or_create_window(vfs_path)
		local window = api.windows[vfs_path]
		if window then return window end

		local ext = lib.get_file_ext(vfs_path)
		if not ext then return end 

		local full_path = editor.files.vfs_path_to_full_path(vfs_path)
		if not full_path then return end 
		
		if ext == "ini" then 
			window = require 'windows.ini.wnd_ini' .new(editor, vfs_path, full_path)
		elseif ext == "csv" then
			window = require 'windows.csv.wnd_csv' .new(editor, vfs_path, full_path)
		elseif ext == "map" then
			window = require 'windows.map.wnd_map' .new(editor, vfs_path, full_path)
		elseif ext == "def" then
			window = require 'windows.def.wnd_def' .new(editor, vfs_path, full_path)
		elseif ext == "style" then
			window = require 'windows.style.wnd_style' .new(editor, vfs_path, full_path)
		end
		if window then 
			api.windows[vfs_path] = window
		end 
		return window
	end

	---@return ly.game_editor.wnd_base
	function api.find_window(path)
		return api.windows[path]
	end 

	return api
end

return {new = new}