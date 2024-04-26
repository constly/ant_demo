local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "rmlui_01_system",
    category        = mgr.type_rmlui,
    name            = "01_基础控件",
    file            = "rmlui/rmlui_01.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)
local ImGui     = require "imgui"
local iRmlUi = ecs.require "ant.rmlui|rmlui_system"
local font = import_package "ant.font"
font.import "/pkg/ant.resources.binary/font/Alibaba-PuHuiTi-Regular.ttf"

local ui
local desc = 
[[
1. 右边的ui为rmlui_01.html\n
2. 修改ui布局后,点击刷新立即起效\n
3. 可以加一种UI编辑模式,\n该模式下每隔1秒自动重载UI,\n可以达到实时修改,实时预览
]]
local desc2 = 
[[
问题:
1. 窗口/全屏后, ui文字适配会出问题
2. 全屏后,ui会等比放大,希望有地方可以调节适配模式 
3. ui动画怎么做
]]

function system.init()
	desc = desc:gsub("\\n", "\n")
end

function system.on_entry()
    ui = iRmlUi.open ("rmlui_01", "/pkg/demo/rmlui/rmlui_01.html")

	-- 注册事件
    iRmlUi.onMessage("click", function (msg)
        print(msg)
		iRmlUi.sendMessage("rmlui_01.test", msg)
    end)
	
	-- 发送消息, 只push, 不阻塞
	iRmlUi.sendMessage("rmlui_01.test", "hello send")
end

function system.on_leave()
	iRmlUi.onMessage("click", nil)
	ui.close()
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(300, 600)
    if ImGui.Begin("debug_ui", nil, ImGui.WindowFlags {"NoMove", "NoTitleBar", "NoResize"}) then 
		ImGui.TextWrapped(desc, 300)
		ImGui.NewLine()
		if ImGui.ButtonEx("刷 新", 100) then 
			system.on_leave()
			system.on_entry()
		end
		ImGui.NewLine()
		ImGui.TextWrapped(desc2, 300)
	end
	ImGui.End()
end