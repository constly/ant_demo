-------------------------------------------------
--- 地图主界面
-------------------------------------------------
---@type game_01.ui.main
local main = import_package 'game_01.ui'
local model = main.create_ui(window, {})

function model.test()
	print("window is2", window)
	print("click test")
end