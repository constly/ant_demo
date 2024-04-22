-----------------------------------------------------------------------
--- 存档助手界面
-----------------------------------------------------------------------

---@class sims.client.wnd_saved.savedata
---@field time string 存档时间
---@field explain string 存档备注
---@field save_id string 存档id

---@param client sims.client
local function new(client)
	---@class sims.debug.wnd_saved
	local api = {}
	local ImGui  = require "imgui"

	---@type ly.game_editor.editor
	local editor
	local input_buf = ImGui.StringBuf()
	local cur_line_idx
	local is_dirty = false
	local curType = 1
	local tbTypes = {
		"自动存档/读档",
		"新建存档",
		"啥都不做",
	}

	---@type sims.client.wnd_saved.savedata[]
	local tb_saves = {
		{time = "2024.04.22", explain = "存档", },
		{time = "2024.04.22", explain = "存档", },
		{time = "2024.04.22", explain = "存档", },
	}

	function api.init(_editor)
		editor = _editor
	end

	--- 得到服务器重启类型
	function api.get_restart_type()
		if curType == 1 then return "save_and_load"
		elseif curType == 2 then return "new_save"
		else return nil end
	end

	local function draw_save_list(size_x)
		ImGui.BeginGroup()
		for i, v in ipairs(tb_saves) do 
			ImGui.Text(string.format("%d.", i))

			ImGui.SameLineEx(20)
			ImGui.Text(v.time)

			ImGui.SameLineEx(130)
			if i == cur_line_idx then 
				ImGui.SetNextItemWidth(150)
				if ImGui.InputText("##tabel_input_cell", input_buf, ImGui.InputTextFlags {'AutoSelectAll', "EnterReturnsTrue"}) then 
					cur_line_idx = nil
					v.explain = tostring(input_buf)
					is_dirty = true
				end
			else 
				local label = string.format("%s##btn_desc_%d", v.explain or "备注说明", i)
				editor.style.draw_style_btn(label, editor.GStyle.btn_transp_center) 
				if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
					cur_line_idx = i
					input_buf:Assgin(v.explain or "备注说明")
				end
			end

			ImGui.SameLineEx(math.min(size_x - 110, 300))
			local label = string.format(" 应 用 ##btn_apply_%d", i)
			if editor.style.draw_btn(label, true) then 
				client.call_server(client.msg.rpc_restart, {type = "load", save_id = v.save_id})
			end
			ImGui.SameLine()
			local label = string.format(" 删 除 ##btn_delete_%d", i)
			if editor.style.draw_btn(label, false) then 
			end
			ImGui.Separator()
		end
		ImGui.EndGroup()
	end

	local function draw_bottom()
		ImGui.BeginGroup()
		ImGui.Text("当数据变化时:")
		ImGui.SameLine()
		ImGui.SetNextItemWidth(150)
		if ImGui.BeginCombo("##combo1", tbTypes[curType] or "") then
			for i, name in ipairs(tbTypes) do
				if ImGui.Selectable(name, i == curType) then
					curType = i
				end
			end
			ImGui.EndCombo()
		end
		ImGui.Dummy(5, 1)
		if editor.style.draw_btn(" 立刻存档 ##btn_save", false) then 
			client.call_server(client.msg.rpc_restart, {type = "only_save"})
		end
		ImGui.SameLine()
		if editor.style.draw_btn(" 重新读档 ##btn_reload", false) then 
			client.call_server(client.msg.rpc_restart, {type = "load_last"})
		end
		ImGui.SameLine()
		if editor.style.draw_btn(" 新开存档 ##btn_new_save", false) then 
			client.call_server(client.msg.rpc_restart, {type = "new_save"})
		end
		ImGui.EndGroup()
	end

	function api.update(is_active, delta_time)
		local size_x, size_y = ImGui.GetContentRegionAvail()
		local header_y = 0;
		local bottom_y = 100
		ImGui.SetCursorPos(0, header_y)
		ImGui.BeginChild("##body", size_x, size_y - header_y - bottom_y, ImGui.ChildFlags{'Border'})
			ImGui.SetCursorPos(5, 5)
			draw_save_list(size_x)
		ImGui.EndChild()

		ImGui.SetCursorPos(10, size_y - bottom_y + 10)
		draw_bottom()

		if is_active then 
			if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
				if ImGui.IsKeyPressed(ImGui.Key.S, false) then 
					api.save() 
				end
			end
		end
	end 

	---@return boolean 文件是否有修改
	function api.is_dirty()
		return is_dirty
	end

	function api.reload()
	end

	function api.close()
	end 

	function api.save()
		is_dirty = false
		editor.msg_hints.show("保存成功", "ok")
	end 

	return api
end

return {new = new}