-----------------------------------------------------------------------
--- 开发计划界面
-----------------------------------------------------------------------

---@param client sims.client
local function new(client)
	local api = {}
	local ImGui  = require "imgui"

	---@type ly.game_editor.editor
	local editor

	local tb_todo = {
		"服务器存档/读档流程走通",
		"客户端状态机:加入房间,创建角色,进入地图",
		"客户端/服务器移动流程走通",
		"多人开房间流程走通 (可能会用状态机来管理客户端)",
		"寻路走通，鼠标点击格子，其他npc自动走过去",
		"goap规划",
		"当文件目录发生变化时，编辑器自动刷新",
	}

	local tb_complete = {
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