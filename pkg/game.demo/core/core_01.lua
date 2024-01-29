local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_01_system",
    category        = mgr.type_core,
    name            = "01_world&pipeline",
    file            = "core/core_01.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		local offset = 50;
		local offset2 = 25
		ImGui.SameLine(offset)
		ImGui.BeginGroup()
		ImGui.Text("一. 演示动态创建world 和 定义pipeline")
		ImGui.NewLine(); ImGui.SameLine(offset2)
			ImGui.BeginGroup()
			ImGui.Text("1. 使用的feature为: game.test.ecs")
			ImGui.Text("2. 在game.test.ecs的package.ecs中 定义了4个pipeline: init, update, game_update, exit")
			ImGui.Text("3. 其中init, update, exit三个pipeline由系统的api自动调用")
			ImGui.Text("4. pipeline中可以定义子pipeline")
			ImGui.Text("5. 在test_sytem.lua中实现了总共5个stage")
			ImGui.Text("6. 程序在连续调用了pipeline的init, 5次update, exit后销毁了world")
			if ImGui.Button("执 行 ##btn_world_01", 80) then 
				system.create_world_01();
			end
			ImGui.EndGroup()
		ImGui.EndGroup()

		ImGui.Dummy(1, 30); ImGui.NewLine(); ImGui.SameLine(offset)
		ImGui.BeginGroup()
		ImGui.Text("二. 演示在world中订阅消息和发送消息")
		ImGui.NewLine(); ImGui.SameLine(offset2)
			ImGui.BeginGroup()
			ImGui.Text("1. 动态创建空World，没有使用feature")
			ImGui.Text("2. 演示了world的 sub, pub, unsub 的用法")
			if ImGui.Button("执 行 ##btn_world_02", 80) then 
				system.create_world_02();
			end
			ImGui.EndGroup()
		ImGui.EndGroup()

	end 
	ImGui.End()
end

function system.create_world_01()
	local config = {
        ecs = {
			feature = {
				"game.test.ecs"
			}
		},
    }
	--[[
	问题
		1. 如何新开一个服务，并且在新的服务器里面启动new_world，最后如何关闭这个服务
	--]]
	local ecs = import_package "ant.ecs"
	local world = ecs.new_world(config)

	-- 系统要求有三个默认的pipeline，分别是init, update，exit 
	-- 分别由这三个函数触发：world:pipeline_init(), world:pipeline_update(), world:pipeline_exit()
	-- pipeline中可以嵌套其他pipeline

	-- 执行 game.test.ecs/package.ecs 下面的 init pipeline
	world:pipeline_init()
	for i = 1, 5 do 
		-- 这会调用到 ant.inputmgr 中去，用于更新窗口事件
		world:dispatch_message { type = "update" }
		world:pipeline_update()
	end
	world:pipeline_exit()
    world = nil
end


function system.create_world_02()
	local config = { ecs = { feature = {} } }
	local ecs = import_package "ant.ecs"
	local world = ecs.new_world(config)

	-- 注册消息监听，一般写在system的 init 函数中
	local event_mb = world:sub {"test_event_group", "event_name"}
	world:pipeline_init()

	-- 发送消息
	world:pub {"test_event_group", "event_name", "abc"}

	-- 处理事件，一般写在system的 data_changed 函数中
	for _, _, v in event_mb:unpack() do
        print("v is", v)
    end

	-- 注销消息监听，一般写在system的 exit 函数中
	world:unsub(event_mb)

	world:pipeline_exit()
	world = nil
end