-------------------------------------------------
--- 地图主界面
-------------------------------------------------
---@type game_01.ui.main
local main = import_package 'game_01.ui'
local view = main.create_ui(window, {})
local args = {...}

function view.test()
	print("window is2 test", window, window.getName(), args[1])
	--print("click test")
end


function view.on_btn_click_return()
	view.open_ui("ui_entry")
end