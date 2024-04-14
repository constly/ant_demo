--------------------------------------------------------
--- sesctions 数据管理
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@class ly.game_editor.goap.node.body.section.line 
---@field actions goap.action.data[] 

---@class ly.game_editor.goap.node.body.section 段落
---@field lines ly.game_editor.goap.node.body.section.line[] 

---@param editor ly.game_editor.editor
---@param stack common_data_stack
---@param goap_handler ly.game_editor.goap.handler
---@param goap_render ly.game_editor.goap.renderer
local function new(editor, stack, goap_handler, goap_render)
	---@class ly.game_editor.goap.body.sections
	local api = {}

	local function create_section()
		local tb = {
			lines = {{actions = {{}}}}, 
		}
		return tb
	end

	local drop_from

	---@param node ly.game_editor.goap.node
	function api.init(node)
		---@type ly.game_editor.goap.node.body.section
		local section = create_section()
		node.body.data = {section}
	end

	local function set_selected_inner(node, section_idx, lineIdx, i)
		local cache = goap_handler.get_body_cache(node.id)
		cache.is_shift = false
		if not cache.selected or type(cache.selected) ~= "table" then cache.selected = {} end 
		
		if not cache.selected or #cache.selected ~= 1 
			or cache.selected[1][1] ~= section_idx or cache.selected[1][2] ~= lineIdx or cache.selected[1][3] ~= i then
			cache.selected = (section_idx and lineIdx) and {{section_idx, lineIdx, i}} or {}
			return true
		end
	end

	local function add_selected(node, section_idx, lineIdx, actionIdx)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected then cache.selected = {} end 
		cache.is_shift = false
		for _, v in ipairs(cache.selected) do 
			if v[1] == section_idx and v[2] == lineIdx and v[3] == actionIdx then 
				return false
			end
		end
		for i = #cache.selected, 1, -1 do 
			local v = cache.selected[i]
			if not v[1] or v[1] ~= section_idx then 
				table.remove(cache.selected, i)
			end
		end
		table.insert(cache.selected, {section_idx, lineIdx, actionIdx})
		return true
	end

	local function add_selected_shift(node, section_idx, lineIdx, actionIdx)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or not section_idx or not lineIdx then 
			return 
		end
		if type(cache.selected[1]) == "table" then 
			local first = cache.selected[1]
			if not first[1] or first[1] ~= section_idx then 
				return
			end
			cache.selected = {first, {section_idx, lineIdx, actionIdx}}
		else 
			cache.selected = {{section_idx, lineIdx, actionIdx}}
		end 
		cache.is_shift = true
	end

	local function set_selected(node, section_idx, lineIdx, i)
		goap_handler.clear_selected(node)
		return set_selected_inner(node, section_idx, lineIdx, i)
	end

	local function is_selected(node, section_idx, lineIdx, actionIdx)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected then return end 

		for i = #cache.selected, 1, -1 do 
			local v = cache.selected[i]
			if not v or not v[1] then 
				table.remove(cache.selected, i)
			end
		end

		if cache.is_shift and #cache.selected == 2 then 
			local first = cache.selected[1]
			local second = cache.selected[2]
			if first[1] ~= section_idx then 
				return false 
			end 

			local min_line = math.min(first[2], second[2])
			local max_line = math.max(first[2], second[2])
			local min_action = math.min(first[3], second[3])
			local max_action = math.max(first[3], second[3])
			if not min_line or not max_line or not min_action or not max_action then 
				return false
			end
			return lineIdx >= min_line and lineIdx <= max_line and actionIdx >= min_action and actionIdx <= max_action
		else
			for _, _v in ipairs(cache.selected or {}) do 
				if _v[1] == section_idx and _v[2] == lineIdx and _v[3] == actionIdx then 
					return true
				end
			end
		end
	end

	---@param node ly.game_editor.goap.node
	---@return goap.action.data 得到选中的行为
	function api.get_first_selected_action(node)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected == 2 then 
			return 
		end 
		for _, v in ipairs(cache.selected or {}) do 
			local section = node.body.data[v[1]]
			if not section then return end 
			local line = section.lines[v[2]]
			if not line then return end 
			return line.actions[v[3]] 
		end
	end

	function api.get_selected_count(node)
		local cache = goap_handler.get_body_cache(node.id)
		return cache.selected and #cache.selected
	end

	---@param node ly.game_editor.goap.node
	---@return goap.action.data[][] 得到选中的行为
	function api.get_selected_actions(node)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or not cache.selected[1] then 
			return 
		end 

		local function get_action(section_idx, line_idx, action_idx)
			local section = node.body.data[section_idx]
			if not section then return end
			local line = section.lines[line_idx]
			if not line then return end 
			return line.actions[action_idx]
		end

		if cache.is_shift and #cache.selected == 2 then 
			local first = cache.selected[1]
			local second = cache.selected[2]
			local section_idx = first[1]
			local min_line = math.min(first[2], second[2])
			local max_line = math.max(first[2], second[2])
			local min_action = math.min(first[3], second[3])
			local max_action = math.max(first[3], second[3])
			if not min_line or not max_line or not min_action or not max_action then 
				return 
			end
			local ret = {}
			local ids = {}
			for i = min_line, max_line do 
				local tb = {}
				for j = min_action, max_action do 
					local action = get_action(section_idx, i, j)
					if action then 
						table.insert(tb, action)
						table.insert(ids, {section_idx, i, j})
					end
				end
				table.insert(ret, tb)
			end
			return ret, ids
		else
			local tb = {}
			local section_idx
			for _, _v in ipairs(cache.selected or {}) do 
				table.insert(tb, {_v[2], _v[3]})
				section_idx = _v[1]
			end
			table.sort(tb, function(a, b)
				if a[1] == b[1] then 
					return a[2] < b[2]
				end
				return a[1] < b[1]
			end)
			local ret = {}
			local ids = {}
			for i, v in ipairs(tb) do 
				local action = get_action(section_idx, v[1], v[2])
				if action then 
					table.insert(ret, {action})
					table.insert(ids, {section_idx, v[1], v[2]})
				end
			end
			return ret, ids
		end
	end 

	---@param node ly.game_editor.goap.node
	function api.reset_all_selected(node)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or not cache.selected[1] then 
			return 
		end 
		local function reset_action(section_idx, line_idx, action_idx)
			local section = node.body.data[section_idx]
			if not section then return end
			local line = section.lines[line_idx]
			local tb = line and line.actions[action_idx]
			if not tb then return end 
			if tb.id then 
				line.actions[action_idx] = {}
				return true
			end
		end

		if cache.is_shift and #cache.selected == 2 then 
			local first = cache.selected[1]
			local second = cache.selected[2]
			local section_idx = first[1]
			local min_line = math.min(first[2], second[2])
			local max_line = math.max(first[2], second[2])
			local min_action = math.min(first[3], second[3])
			local max_action = math.max(first[3], second[3])
			if not min_line or not max_line or not min_action or not max_action then 
				return 
			end
			local ret = false
			for i = min_line, max_line do 
				for j = min_action, max_action do 
					ret = reset_action(section_idx, i, j) or ret
				end
			end
		else
			local ret = false
			for _, _v in ipairs(cache.selected or {}) do 
				ret = reset_action(_v[1], _v[2], _v[3]) or ret
			end
			return ret
		end
	end

	---@param node ly.game_editor.goap.node
	function api.paster(node, data)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected == 0 then
			return 
		end

		local section_idx, line_idx, action_idx
		for i, v in ipairs(cache.selected or {}) do 
			if i == 1 then 
				section_idx, line_idx, action_idx = v[1], v[2], v[3]
			else 
				line_idx = math.min(line_idx, v[2])
				action_idx = math.min(action_idx, v[3])
			end
		end

		local function set_action(section_idx, line_idx, action_idx, data)
			local section = node.body.data[section_idx]
			if not section then return end
			for i, line in ipairs(section.lines) do 
				for j = 1, action_idx do 
					line.actions[j] = line.actions[j] or {}
				end
			end
			local line = section.lines[line_idx]
			if not line then 
				line = {actions = {}}
				for i = 1, #section.lines[1].actions do 
					table.insert(line.actions, {})
				end 
				table.insert(section.lines, line)
			end
			for i = 1, action_idx do 
				if not line.actions[i] then 
					line.actions[i] = {}
				end
			end
			line.actions[action_idx] = data
		end
		
		for i = 1, #data do 
			local line = data[i]
			for j = 1, #line do 
				local _line = line_idx + i - 1
				local _action = action_idx + j - 1
				set_action(section_idx, _line, _action, line[j])
			end
		end
		return true
	end

	---@param node ly.game_editor.goap.node
	function api.clear_selected(node)
		set_selected_inner(node, nil)
	end

	---@param node ly.game_editor.goap.node
	---@param data ly.game_editor.goap.node.body.section
	local function draw_section(node, section_idx, data)
		local item_len_x = 250
		for lineIdx, line in ipairs(data.lines) do 
			for i, action in ipairs(line.actions) do 
				local selected = is_selected(node, section_idx, lineIdx, i)
				local style = action.disable and GStyle.btn_left_disable or GStyle.btn_left
				style = selected and GStyle.btn_left_selected or style
				local desc = editor.tbParams.goap_mgr.get_action_desc(action) or ""
				local label = string.format("%s##btn_line_%d_%d_%d", desc, section_idx, lineIdx, i)
				if editor.style.draw_style_btn(label, style, {size_x = item_len_x}) then
					local ok = false 
					if ImGui.IsKeyDown(ImGui.Key.LeftCtrl) then 
						ok = add_selected(node, section_idx, lineIdx, i)
					elseif ImGui.IsKeyDown(ImGui.Key.LeftShift) then 
						ok = add_selected_shift(node, section_idx, lineIdx, i)
					else
						ok = set_selected(node, section_idx, lineIdx, i)
					end 
					if ok then 
						stack.snapshoot(false)
					end
				end
				if ImGui.BeginDragDropSource() then 
					if set_selected(node, section_idx, lineIdx, i) then 
						stack.snapshoot(false)
					end
					drop_from = action
					imgui_utils.SetDragDropPayload("DragGoapAction", "1");
					ImGui.Text("正在拖动 " .. desc);
					ImGui.EndDragDropSource();
				end

				if imgui_utils.GetDragDropPayload("DragGoapAction") and ImGui.BeginDragDropTarget() then 
					local payload = imgui_utils.AcceptDragDropPayload("DragGoapAction")
					if payload and drop_from then
						lib.swap_table(drop_from, action)
						set_selected(node, section_idx, lineIdx, i) 
						stack.snapshoot(true)
						drop_from = nil
					end
					ImGui.EndDragDropTarget()
				end

				if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
					---@type ly.game_editor.action.selector.params
					local param = {}
					param.selected = {}
					param.callback = function(id)
						action.id = id
						action.params = {}
						stack.snapshoot(true)
					end
					goap_render.action_selector.open(param)
				end

				if ImGui.BeginPopupContextItem() then 
					if set_selected(node, section_idx, lineIdx, i) then 
						stack.snapshoot(false)
					end
					if ImGui.MenuItem("清 空") then
						action.id = ""
						action.params = {}
						stack.snapshoot(true)
					end 
					if not action.disable and ImGui.MenuItem("禁 用") then
						action.disable = true
						stack.snapshoot(true)
					end
					if action.disable and ImGui.MenuItem("激 活") then 
						action.disable = nil
						stack.snapshoot(true)
					end
					if #data.lines > 1 and ImGui.MenuItem("删除本行") then
						table.remove(data.lines, lineIdx)
						stack.snapshoot(true)
					end 
					if #line.actions > 1 and ImGui.MenuItem("删除本列") then
						for _, line in ipairs(data.lines) do 
							table.remove(line.actions, i)
						end
						stack.snapshoot(true)
					end 
					ImGui.EndPopup()
				end
				ImGui.SameLine()
			end
			if lineIdx == 1 then 
				local label = string.format(" + ##btn_add_column_%d", section_idx)
				if editor.style.draw_color_btn(label, {0.15, 0.15, 0.15, 1}, {0.5, 0.5, 0.5, 1}) then 
					for i, line in ipairs(data.lines) do 
						table.insert(line.actions, {})
					end
					stack.snapshoot(true)
				end
				ImGui.SameLine()
				ImGui.Dummy(5, 10)
				ImGui.SameLineEx(-50)
				local label = string.format("Sec%d##btn_sec_%d", section_idx, section_idx)
				if editor.style.draw_color_btn(label, {0.15, 0.15, 0.15, 1}, {0.8, 0.8, 0.8, 1}) then 
				end
				if ImGui.BeginPopupContextItem() then 
					if ImGui.MenuItem("新 增") then
						local section = create_section()
						table.insert(node.body.data, section_idx + 1, section)
						stack.snapshoot(true)
					end 
					if #node.body.data > 1 and ImGui.MenuItem("删 除") then
						table.remove(node.body.data, section_idx)
						stack.snapshoot(true)
					end 
					ImGui.EndPopup()
				end
			else 
				ImGui.NewLine()
			end
		end
		local label = string.format(" + ##btn_add_line_%d", section_idx)
		if editor.style.draw_color_btn(label, {0.15, 0.15, 0.15, 1}, {0.5, 0.5, 0.5, 1}) then 
			local n = 0
			if data.lines[1] then 
				n = #data.lines[1].actions 
			end
			n = math.max(1, n)
			local tb = {}
			for i = 1, n do 
				table.insert(tb, {})
			end
			table.insert(data.lines, {actions = tb})
			stack.snapshoot(true)
		end
		ImGui.Dummy(10, 10)
	end

	---@param node ly.game_editor.goap.node
	function api.draw(node, delta_time, size_x)
		for i, v in ipairs(node.body.data) do 
			draw_section(node, i, v)
		end
	end

	return api
end

return {new = new}