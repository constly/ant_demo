--------------------------------------------------------
--- fsm 状态机 数据管理
--------------------------------------------------------
---
local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param stack common_data_stack
---@param goap_handler ly.game_editor.goap.handler
---@param goap_render ly.game_editor.goap.renderer
local function new(editor, stack, goap_handler, goap_render)
	---@class ly.game_editor.goap.body.fsm
	local api = {}

	---@param node ly.game_editor.goap.node
	function api.init(node)
		
	end

	local function set_selected_inner(node, v)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected > 1 or cache.selected[1] ~= v then
			cache.selected = v and {v} or {}
			return true
		end
	end

	local function set_selected(node, v)
		set_selected_inner(node, v)
		goap_handler.clear_selected(node)
	end

	local function is_selected(node, v)
		local cache = goap_handler.get_body_cache(node.id)
		for i, _v in ipairs(cache.selected or {}) do 
			if _v == v then 
				return true
			end
		end
	end

	---@return goap.action.data 得到选中的行为
	function api.get_first_selected_action(node)
		return nil
	end

	function api.get_selected_count(node)
		local cache = goap_handler.get_body_cache(node.id)
		return cache.selected and #cache.selected
	end

	---@param node ly.game_editor.goap.node
	---@return goap.action.data[] 得到选中的行为
	function api.get_selected_actions(node)
		return {}
	end 

	---@param node ly.game_editor.goap.node
	function api.reset_all_selected(node)
	end

	---@param node ly.game_editor.goap.node
	function api.paster(node, data)
		return false
	end

	---@param node ly.game_editor.goap.node
	function api.clear_selected(node)
		set_selected_inner(node, nil)
	end

	function api.draw(node, delta_time, size_x)
		ImGui.Text("fsm")
	end

	return api
end

return {new = new}