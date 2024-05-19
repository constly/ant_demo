-----------------------------------------------------------------------
--- 开发计划界面
-----------------------------------------------------------------------

---@param client sims.client
local function new(client)
	local api = {}
	local ImGui  = require "imgui"

	---@type ly.game_editor.editor
	local editor

	--[[
		1. 格子分为四类: 装饰，地形，物件，逻辑。客户端不会实例化逻辑格子
		2. 最多支持128种地形（创建存档时，会新建索引）
		3. 每个number可以存储8个地形，这样一个区域最多需要: 20*20*20/8 = 1000个number 存储地形
		4. 每个区域的装饰和物件分别存储，装饰也也通过服务器下发？这个需要斟酌下
		5. 服务器同步地形时，可以略微压缩下，形如:{{id1, num1}, {id2, num2}}，这样可以很好的压缩一样的格子
		6. 区域需要有单独的数据变化同步协议
		
	-- ]]

	local tb_todo = {
		"优化sims服务器架构，尽量拆分为service",
		"声音支持播放mp3，wav实在太大了",
		"客户端角色移动平滑插值",
		"寻路走通，鼠标点击格子，其他npc自动走过去",
		"goap规划",
		"服务器存档/读档流程走通",
	}

	local tb_complete = {
		"场景构造和同步走通",
		"客户端状态机:加入房间,创建角色,进入地图",
		"多人开房间流程走通 (可能会用状态机来管理客户端)",
		"客户端/服务器移动流程走通",
		"当文件目录发生变化时，编辑器自动刷新",
		"space布局文件入库",
	}

	function api.init(_editor)
		editor = _editor
	end

	function api.update(is_active, delta_time)
		ImGui.SetCursorPos(10, 10)
		ImGui.BeginGroup()
			ImGui.TextColored(0.9, 0.9, 0, 1, "计划中:")
			ImGui.Dummy(5, 5)
			ImGui.SameLine()
			ImGui.BeginGroup()
			for i, msg in ipairs(tb_todo) do 
				ImGui.Text("%d. %s", i, msg)
			end
			ImGui.EndGroup()
		ImGui.EndGroup()

		ImGui.Dummy(10, 10)
		local x, y = ImGui.GetCursorPos()
		ImGui.SetCursorPos(10, y)
		ImGui.BeginGroup()
			ImGui.TextColored(0.0, 0.9, 0, 1, "已完成:")
			ImGui.Dummy(5, 5)
			ImGui.SameLine()
			ImGui.BeginGroup()
			for i, msg in ipairs(tb_complete) do 
				ImGui.Text("%d. %s", i, msg)
			end
			ImGui.EndGroup()
		ImGui.EndGroup()
	end
	
	return api
end

return {new = new}