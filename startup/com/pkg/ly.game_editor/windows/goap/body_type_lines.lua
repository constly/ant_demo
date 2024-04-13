--------------------------------------------------------
--- lines 数据管理
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui


---@param editor ly.game_editor.editor
---@param stack common_data_stack
---@param goap_handler ly.game_editor.goap.handler
---@param goap_render ly.game_editor.goap.renderer
local function new(editor, stack, goap_handler, goap_render)
	---@class ly.game_editor.goap.body.lines
	local api = {}

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
	function api.get_selected_action(node)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected ~= 1 then return end
		local first = cache.selected[1]
		return node.body.data[first];
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
			local desc = editor.tbParams.goap_mgr.get_action_desc(v)
			local label = string.format("%s##btn_line_%d", desc, i)
			if editor.style.draw_style_btn(label, style, {size_x = item_len_x}) then 
				if set_selected(node, i) then 
					stack.snapshoot(false)
				end 
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