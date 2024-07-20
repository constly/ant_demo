-------------------------------------------------
--- 游戏设置界面
-------------------------------------------------
---@type game_01.ui.main
local main = import_package 'game_01.ui'
local view = main.create_ui(window, {})

function view.on_btn_click_return()
	view.open_ui("ui_entry")
end