--------------------------------------------------------
--- sesctions 数据管理
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui


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

	---@param node ly.game_editor.goap.node
	function api.init(node)
		---@type ly.game_editor.goap.node.body.section
		local section = create_section()
		node.body.data = {section}
	end

	local function set_selected_inner(node, section_idx, lineIdx, i)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected > 1 
			or cache.selected[1] ~= section_idx or cache.selected[2] ~= lineIdx or cache.selected[3] ~= i then
			cache.selected = section_idx and {{section_idx, lineIdx, i}} or {}
			return true
		end
	end

	local function set_selected(node, section_idx, lineIdx, i)
		goap_handler.clear_selected(node)
		return set_selected_inner(node, section_idx, lineIdx, i)
	end

	local function is_selected(node, section_idx, lineIdx, actionIdx)
		local cache = goap_handler.get_body_cache(node.id)
		for _, _v in ipairs(cache.selected or {}) do 
			if _v[1] == section_idx and _v[2] == lineIdx and _v[3] == actionIdx then 
				return true
			end
		end
	end

	---@param node ly.game_editor.goap.node
	---@return goap.action.data 得到选中的行为
	function api.get_selected_action(node)
		local cache = goap_handler.get_body_cache(node.id)
		for _, v in ipairs(cache.selected or {}) do 
			local section = node.body.data[v[1]]
			if not section then return end 
			local line = section.lines[v[2]]
			if not line then return end 
			return line.actions[v[3]] 
		end
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
				local desc = editor.tbParams.goap_mgr.get_action_desc(action)
				local label = string.format("%s##btn_line_%d_%d_%d", desc or "", section_idx, lineIdx, i)
				if editor.style.draw_style_btn(label, style, {size_x = item_len_x}) then 
					if set_selected(node, section_idx, lineIdx, i) then 
						stack.snapshoot(false)
					end 
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
			if data.lines[1] then n = #data.lines[1].actions end
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