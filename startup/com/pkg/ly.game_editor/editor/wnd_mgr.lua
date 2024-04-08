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
---@field onAnyFileSaveComplete function 通知文件保存完成(任意)
---@field has_preview_mode function 是否有预览模式
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
		local tab = view.tabs.find_by_path(path)
		if not tab then return end
		local window = api.get_or_create_window(path)
		if window then 
			window.update(is_active, delta_time, tab.show_mode);
		else 
			ImGui.SetCursorPos(5, 5)
			ImGui.TextColored(0.8, 0, 0, 1, "文件不存在: " .. path)
		end		
	end

	---@return ly.game_editor.wnd_base
	function api.get_or_create_window(path)
		local window = api.windows[path]
		if window then return window end

		if lib.start_with(path, editor.__inner_wnd) then 
			local name = lib.split(path, ":")[2]
			if name == "code_analysis" then 
				window = require 'windows._code_analysis.wnd_code_analysis' .new(editor, path, path)
			end
		else
			local ext = lib.get_file_ext(path)
			if not ext then return end 

			local vfs_path =  "/pkg/" .. path
			local full_path = editor.files.vfs_path_to_full_path(path)
			if not full_path then return end 
			
			if ext == "ini" then 
				window = require 'windows.ini.wnd_ini' .new(editor, vfs_path, full_path)
			elseif ext == "csv" or ext == "txt" then
				window = require 'windows.csv.wnd_csv' .new(editor, vfs_path, full_path)
			elseif ext == "map" then
				window = require 'windows.map.wnd_map' .new(editor, vfs_path, full_path)
			elseif ext == "def" then
				window = require 'windows.def.wnd_def' .new(editor, vfs_path, full_path)
			elseif ext == "style" then
				window = require 'windows.style.wnd_style' .new(editor, vfs_path, full_path)
			elseif ext == "tag" then
				window = require 'windows.tag.wnd_tag' .new(editor, vfs_path, full_path)
			elseif ext == "goap" then
				window = require 'windows.goap.wnd_goap' .new(editor, vfs_path, full_path)
			elseif ext == "attr" then
				window = require 'windows.attr.wnd_attr' .new(editor, vfs_path, full_path)
			end
		end
		if window then 
			api.windows[path] = window
		end 
		return window
	end

	---@return ly.game_editor.wnd_base
	function api.find_window(path)
		return api.windows[path]
	end 

	--- 当文件保存完成时
	---@param wnd ly.game_editor.wnd_base 窗口对象
	---@param vfs_path string vfs路径
	---@param full_path string 本地磁盘路径
	function api.when_file_save_complete(wnd, vfs_path, full_path)
		for i, v in pairs(api.windows) do 
			if v ~= wnd and v.onAnyFileSaveComplete then 
				v.onAnyFileSaveComplete(vfs_path, full_path)
			end
		end
	end

	return api
end

return {new = new}