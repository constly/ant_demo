
---@class ly.game_editor
local api = {}

---@class ly.game_editor.custommenu
---@field name string 菜单名字
---@field window ly.game_editor.wnd_base 窗口

---@class ly.game_editor.create_params 编辑器创建参数
---@field roots string[] 文件根目录列表
---@field notify_file_saved function 通知数据发生变化（即有保存操作）
---@field module_name string 模块名
---@field project_root string 项目根目录
---@field pkgs string[] 资源包
---@field theme_path string 主题路径
---@field workspace_path string 工作空间布局文件存储路径
---@field goap_mgr goap_mgr goap节点定义
---@field menus ly.game_editor.custommenu[] 自定义菜单列明
local create_params = {}

--- 创建游戏编辑器
---@param tbParams ly.game_editor.create_params
---@return ly.game_editor.editor
function api.create_editor(tbParams)
	local editor = require 'editor.editor'
	return editor.create(tbParams)
end

--- 创建地图编辑器
---@param args chess_editor_create_args
---@return ly.map.renderer
function api.create_map_editor(args)
	return require 'windows.map.map_renderer'.new(nil, args)
end



return api