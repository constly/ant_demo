
local model = window.createModel {
	show = false,
	label = "新游戏"
}
window.onMessage("rmlui_01.test", function(a)
	print("rmlui_01.html", a)
end)

function model.new(event)
	print("model new", window.callMessage("click", "new"))
	window.sendMessage("click", "new_send")
end

function model.load(event)
	window.callMessage("click", "load")
	model.label = "继续游戏"
end

function model.setting(event)
	window.callMessage("click", "setting")
	model.show = not model.show
end

function model.exit()
	window.callMessage("click", "exit")
end
