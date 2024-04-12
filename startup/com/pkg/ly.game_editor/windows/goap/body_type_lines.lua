--------------------------------------------------------
--- lines 数据管理
--------------------------------------------------------

local dep = require 'dep'
local lib = dep.common.lib
local ImGui = dep.ImGui

---@param editor ly.game_editor.editor
---@param stack common_data_stack
---@param goap_handler ly.game_editor.goap.handler
local function new(editor, stack, goap_handler)
	---@class ly.game_editor.goap.body.lines
	local api = {}

	---@param node ly.game_editor.goap.node
	function api.init(node)
		node.body.data = {{}}
	end

	local function set_selected(node, v)
		local cache = goap_handler.get_body_cache(node.id)
		if not cache.selected or #cache.selected > 1 or cache.selected[1] ~= v then
			cache.selected = {v}
			return true
		end
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
	function api.draw(node, delta_time, size_x)
		local item_len_x = 300
		for i, v in ipairs(node.body.data) do 
			local selected = is_selected(node, v)
			local style = selected and GStyle.btn_left_selected or GStyle.btn_left
			local label = string.format("##btn_line_%d", i)
			if editor.style.draw_style_btn(label, style, {size_x = item_len_x}) then 
				if set_selected(node, v) then 
					stack.snapshoot(false)
				end 
			end
		end
	end

	return api
end

return {new = new}