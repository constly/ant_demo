-----------------------------------------------------------------------
--- 存档助手界面
-----------------------------------------------------------------------
---@type ly.common
local common = import_package 'ly.common'
local lfs = require "bee.filesystem"

---@class sims.client.wnd_saved.savedata
---@field name string 存档名字
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
	local tb_saves = {}
	local filewatch

	function api.init(_editor)
		editor = _editor
		api.refresh()

		local bfw = require "bee.filewatch"
		local fw = bfw.create()
		fw:add(client.saved_root)
		filewatch = fw
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
			if i == cur_line_idx then 
				ImGui.SetNextItemWidth(220)
				if ImGui.InputText("##tabel_input_cell", input_buf, ImGui.InputTextFlags {"AutoSelectAll", "EnterReturnsTrue"}) then 
					cur_line_idx = nil
					v.name = tostring(input_buf)
					is_dirty = true
				end
			else 
				local label = string.format(" %s ##btn_desc_%d", v.name, i)
				ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
				editor.style.draw_color_btn(label, {0.2, 0.2, 0.2, 1}, {0.9, 0.9, 0.9, 1}, {size_x = 220}) 
				if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
					cur_line_idx = i
					input_buf:Assgin(v.name)
				end
				ImGui.PopStyleVar()
				if ImGui.BeginItemTooltip() then 
					local arr = common.lib.split(v.save_id, "_")
					ImGui.Text(string.format("%s年%s月%s日 %s时%s分%s秒", arr[1], arr[2], arr[3], arr[5], arr[6], arr[7]))
					ImGui.EndTooltip()
				end
				if ImGui.BeginPopupContextItem() then
					cur_line_idx = nil
					if ImGui.MenuItem("改 名") then
						cur_line_idx = i
						input_buf:Assgin(v.name)
					end
					if ImGui.MenuItem("删 除") then
						local path = string.format("%s%s.save", client.saved_root, v.save_id)
						lfs.remove(path)
					end
					if ImGui.MenuItem("在文件浏览器中查看") then
						local path = string.format("%s%s.save", client.saved_root, v.save_id)
						os.execute("c:\\windows\\explorer.exe /select,".. path)
					end
					ImGui.EndPopup()
				end
			end

			ImGui.SameLineEx(math.min(size_x - 80, 300))
			local label = string.format(" 应 用 ##btn_apply_%d", i)
			if editor.style.draw_btn(label, true) then 
				client.call_server(client.msg.rpc_restart, {type = "load", save_id = v.save_id})
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

	local function update_filewatch()
		local type, path = filewatch and filewatch:select()
		while type do
			api.refresh()
			return
		end
	end

	function api.update(is_active, delta_time)
		update_filewatch()

		local size_x, size_y = ImGui.GetContentRegionAvail()
		local header_y = 0;
		local bottom_y = 100
		ImGui.SetCursorPos(0, header_y)
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 10, 10)
		ImGui.BeginChild("##body", size_x, size_y - header_y - bottom_y, ImGui.ChildFlags{'Border'})
			ImGui.SetCursorPos(5, 5)
			draw_save_list(size_x)

			if ImGui.IsWindowHovered() and not ImGui.IsAnyItemHovered()  then 
				if ImGui.IsMouseReleased(ImGui.MouseButton.Left) then 
					cur_line_idx = nil
				end
			end
		ImGui.EndChild()

		ImGui.SetCursorPos(10, size_y - bottom_y + 10)
		draw_bottom()
		ImGui.PopStyleVar()

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

	local function get_meta_path()
		return client.saved_root .. "meta.ant"
	end

	function api.save()
		is_dirty = false
		editor.msg_hints.show("保存成功", "ok")
		common.file.save_datalist(get_meta_path(), tb_saves)
	end 

	function api.refresh()
		tb_saves = common.file.load_datalist(get_meta_path()) or {}
		local set = {}
		for item in lfs.pairs(client.saved_root) do
			local filename = common.lib.get_filename_without_ext(tostring(item))
			if filename ~= "meta" then
				local ok = false
				for i, v in ipairs(tb_saves) do 
					if v.save_id == filename then 
						ok = true
						break
					end
				end
				if not ok then
					---@type sims.client.wnd_saved.savedata
					local tb = {}
					tb.save_id = filename
					tb.name = filename
					table.insert(tb_saves, tb)
				end
				set[filename] = true
			end
		end
		for i = #tb_saves, 1, -1 do
			local v = tb_saves[i]
			if not set[v.save_id] then 
				table.remove(tb_saves, i)
			end
		end
		table.sort(tb_saves, function(a, b) return a.save_id > b.save_id end)
	end

	return api
end

return {new = new}