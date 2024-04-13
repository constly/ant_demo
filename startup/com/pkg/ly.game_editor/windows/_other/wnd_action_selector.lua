--------------------------------------------------------
-- tag选择器
--------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui
local imgui_utils = dep.common.imgui_utils

---@class ly.game_editor.action.selector.params
---@field callback function 选择完成完成回调
---@field selected string[] 初始选中


---@param editor ly.game_editor.editor
---@return ly.game_editor.action.selector.api
local function new(editor)
	---@class ly.game_editor.action.selector.api
	local api = {}

	---@type ly.game_editor.action.selector.params
	local params 

	---@type goap_mgr
	local goap_mgr = editor.tbParams.goap_mgr

	local all_actions
	local pop_Id = "Action选择器##pop_action_selector"
	local need_open = false

	local left_x = 120
	local item_x = 230
	local selected_region
	local selected_actions = {}

	---@param _params ly.game_editor.action.selector.params
	function api.open(_params)
		all_actions = goap_mgr.get_all_actions()
		params = _params
		need_open = true
		if #all_actions > 0 then
			selected_region = selected_region or all_actions[1].name
		end
	end

	local function draw_left()
		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()
		for i, v in ipairs(all_actions) do 
			local label = string.format("%s##btn_left_%d", v.name, i)
			local style = selected_region == v.name and GStyle.btn_left_selected or GStyle.btn_left
			if editor.style.draw_style_btn(label, style, {size_x = left_x - 10}) then
				selected_region = v.name
			end
		end
		ImGui.EndGroup()
	end

	local function draw_right()
		local list 
		for i, v in ipairs(all_actions) do 
			if v.name == selected_region then 
				list = v.list
			end
		end
		if not list then return end 

		local sel_id = selected_actions[selected_region] 

		ImGui.SetCursorPos(5, 5)
		ImGui.BeginGroup()
		for i, v in ipairs(list) do 
			local label = string.format("%s##btn_right_%d", v.name, i)
			local style = sel_id == v.id and GStyle.btn_left_selected or GStyle.btn_left
			if editor.style.draw_style_btn(label, style, {size_x = item_x}) then
				selected_actions[selected_region] = v.id
			end
			if ImGui.IsItemHovered() and ImGui.IsMouseDoubleClicked(ImGui.MouseButton.Left) then 
				params.callback(selected_actions[selected_region] )
				ImGui.CloseCurrentPopup()
			end
			if v.desc and ImGui.BeginItemTooltip() then 
				ImGui.Text(v.desc)
				ImGui.EndTooltip()
			end
			if i % 2 == 1 then 
				ImGui.SameLine()
			end
		end
		ImGui.EndGroup()
	end

	function api.update()
		if need_open then 
			ImGui.OpenPopup(pop_Id)
			ImGui.SetNextWindowSize(650, 500)
			need_open = false
		end

		if ImGui.BeginPopupModal(pop_Id, true, ImGui.WindowFlags({})) then 
			local size_x, size_y = ImGui.GetContentRegionAvail()
			local right_x = size_x - left_x - 25
			local size_y = size_y - 50

			ImGui.BeginChild("left", left_x, size_y, ImGui.ChildFlags({"Border"}))
				draw_left()
			ImGui.EndChild()

			ImGui.SameLine()
			ImGui.BeginChild("right", right_x, size_y, ImGui.ChildFlags({"Border"}))
				draw_right()
			ImGui.EndChild()

			ImGui.SetCursorPos(size_x * 0.5 - 30, size_y + 43)
			if editor.style.draw_btn("确 认##btn_ok", true, {size_x = 80}) then 
				params.callback(selected_actions[selected_region] )
				ImGui.CloseCurrentPopup()
			end

			ImGui.EndPopup()
		end		
	end

	return api
end

return {new = new}