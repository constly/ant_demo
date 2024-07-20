-------------------------------------------------
--- 游戏进入界面
-------------------------------------------------
---@type game_01.ui.main
local main = import_package 'game_01.ui'
local view = main.create_ui(window, {})

function view.on_btn_click_new()
	view.open_ui("ui_map", "arg1", "arg2")
end

function view.on_btn_click_setting()
	view.open_ui("ui_setting")
end

function view.on_btn_click_exit()
	window.sendMessage("exit")
end