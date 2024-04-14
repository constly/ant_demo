--------------------------------------------------------
--- lines 数据管理
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@param editor ly.game_editor.editor
---@param stack common_data_stack
---@param goap_handler ly.game_editor.goap.handler
---@param goap_render ly.game_editor.goap.renderer
local function new(editor, stack, goap_handler, goap_render)
	---@class ly.game_editor.goap.body.lines
	local api = {}
	local drop_from 

	---@param node ly.game_editor.goap.node
	function api.init(node)
		node.body.data = {{}}
	end

	local function set_selected_inner(node, v)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected > 1 or cache.selected[1] ~= v then
			cache.selected = v and {v} or {}
			return true
		end
	end

	local function set_selected(node, v)
		goap_handler.clear_selected(node)
		return set_selected_inner(node, v)
	end

	local function is_selected(node, v)
		local cache = goap_handler.get_body_cache(node.id)
		for i, _v in ipairs(cache.selected or {}) do 
			if _v == v then 
				return true
			end
		end
	end

	---@param node ly.game_editor.goap.node
	function api.clear_selected(node)
		set_selected_inner(node, nil)
	end

	---@return goap.action.data 得到选中的行为
	function api.get_first_selected_action(node)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected ~= 1 then return end
		local first = cache.selected[1]
		return node.body.data[first];
	end

	function api.get_selected_count(node)
		local cache = goap_handler.get_body_cache(node.id)
		return cache.selected and #cache.selected
	end

	---@param node ly.game_editor.goap.node
	---@return goap.action.data[] 得到选中的行为
	function api.get_selected_actions(node)
		local tb = {}
		local cache = goap_handler.get_body_cache(node.id)
		for i, v in ipairs(cache.selected or {}) do 
			table.insert(tb, v)
		end
		table.sort(tb, function(a, b) return a < b end)
		local ret = {}
		for i, v in ipairs(tb) do 
			local data = node.body.data[v]
			if data then 
				table.insert(ret, {data})
			end
		end
		return ret 
	end

	---@param node ly.game_editor.goap.node
	function api.reset_all_selected(node)
		local cache = goap_handler.get_body_cache(node.id)
		local ret = false
		for i, v in ipairs(cache.selected or {}) do 
			local data = node.body.data[v]
			if data then 
				node.body.data[v] = {}
				ret = true
			end
		end
		return ret
	end

	---@param node ly.game_editor.goap.node
	function api.paster(node, data)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected == 0 then
			return 
		end
		local min = cache.selected[1]
		for i, v in ipairs(cache.selected or {}) do 
			min = math.min(min, v)
		end

		local lines = node.body.data
		for i = 1, #data do 
			local idx = min + i - 1
			if lines[idx] then 
				lines[idx] = lib.copy(data[i][1])
			else 
				table.insert(lines, lib.copy(data[i][1]))
			end
		end
		return true
	end

	---@param node ly.game_editor.goap.node
	function api.draw(node, delta_time, size_x)
		local item_len_x = 300
		---@type goap.action.data[] 
		local lines = node.body.data
		for i, v in ipairs(lines) do 
			local selected = is_selected(node, i)
			local style = v.disable and GStyle.btn_left_disable or GStyle.btn_left
			style = selected and GStyle.btn_left_selected or style
			local desc = editor.tbParams.goap_mgr.get_action_desc(v) or ""
			local label = string.format("%s##btn_line_%d", desc, i)
			if editor.style.draw_style_btn(label, style, {size_x = item_len_x}) then 
				if set_selected(node, i) then 
					stack.snapshoot(false)
				end 
			end

			if ImGui.BeginDragDropSource() then 
				if set_selected(node, i) then 
					stack.snapshoot(false)
				end
				drop_from = v
				imgui_utils.SetDragDropPayload("DragGoapAction", "1");
				ImGui.Text("正在拖动 " .. desc);
				ImGui.EndDragDropSource();
			end

			if imgui_utils.GetDragDropPayload("DragGoapAction") and ImGui.BeginDragDropTarget() then 
				local payload = imgui_utils.AcceptDragDropPayload("DragGoapAction")
				if payload and drop_from then
					lib.swap_table(drop_from, v)
					set_selected(node, i) 
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
					v.id = id
					v.params = {}
					stack.snapshoot(true)
				end
				goap_render.action_selector.open(param)
			end

			if ImGui.BeginPopupContextItem() then 
				if set_selected(node, i) then 
					stack.snapshoot(false)
				end
				if ImGui.MenuItem("新 增") then
					local tb = {}
					table.insert(lines, i + 1, tb)
					set_selected(node, i)
					stack.snapshoot(true)
				end 
				if ImGui.MenuItem("清 空") then
					lines[i] = {}
					stack.snapshoot(true)
				end 
				if not v.disable and ImGui.MenuItem("禁 用") then
					v.disable = true
					stack.snapshoot(true)
				end
				if v.disable and ImGui.MenuItem("激 活") then 
					v.disable = nil
					stack.snapshoot(true)
				end
				if i > 1 and ImGui.MenuItem("上 移") then
					table.insert(lines, i - 1, table.remove(lines, i))
					stack.snapshoot(true)
				end
				if i < #lines and ImGui.MenuItem("下 移") then
					table.insert(lines, i + 1, table.remove(lines, i))
					stack.snapshoot(true)
				end
				if #lines > 1 and ImGui.MenuItem("删 除") then
					table.remove(lines, i)
					stack.snapshoot(true)
				end
				ImGui.EndPopup()
			end
		end
	end

	return api
end

return {new = new}