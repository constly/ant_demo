--------------------------------------------------------
-- tag选择器
--------------------------------------------------------
local dep = require 'dep'
---@type ly.game_core
local game_core = import_package 'ly.game_core'
local ImGui = dep.ImGui

---@class ly.game_editor.tag.selector.params
---@field path string 文件路径
---@field callback function 选择完成完成回调
---@field is_multi boolean 是否多选
---@field selected string[] 初始选中


---@param editor ly.game_editor.editor
---@return ly.game_editor.tag.selector.api
local function new(editor)
	---@class ly.game_editor.tag.selector.api
	local api = {}

	---@type ly.game_editor.tag.selector.params
	local params 

	---@type ly.game_core.tag.data
	local data

	local stack = dep.common.data_stack.create()								---@type common_data_stack
	local data_hander = game_core.create_tag_handler()							---@type ly.game_core.tag.handler

	local pop_Id = "Tag选择器##pop_tag_selector"

	local need_open = false

	---@param _params ly.game_editor.tag.selector.params
	function api.open(_params)
		params = _params
		data = dep.common.file.load_datalist(_params.path)

		stack.set_data_handler(data_hander)
		data_hander.set_data(data)
		data_hander.set_selected()
		if params.selected then 
			for i, v in ipairs(params.selected) do 
				data_hander.add_selected(v)
			end
		end
		stack.snapshoot(false)
		need_open = true
	end

	local function depth_to_str(n)
		n = n or 1
		local tb = {}
		for i = 1, n do 
			table.insert(tb, "")
		end
		return table.concat(tb, "        ")
	end

	---@param data ly.game_core.tag.data
	local function draw_item(data, depth, size_x)
		local selected = data_hander.is_selected(data.name) 
		local style = selected and GStyle.tag_active or GStyle.tag_normal
		local desc = (data.desc and data.desc ~= "") and string.format("(%s)", data.desc) or ""
		local str = string.format("%s%s %s##btn_tag_%s", depth_to_str(depth), data.name, desc, data.name)
		if editor.style.draw_style_btn(str, style, {size_x = size_x}) then 
			if params.is_multi then 
				if selected then 
					data_hander.remove_selected(data.name)
				else
					data_hander.add_selected(data.name)
				end
			else 
				data_hander.set_selected(data.name)
			end
		end
		for i, v in ipairs(data.children) do 
			draw_item(v, depth + 1, size_x)
		end
	end

	function api.update()
		if need_open then 
			ImGui.OpenPopup(pop_Id)
			ImGui.SetNextWindowSize(400, 400)
			need_open = false
		end

		if ImGui.BeginPopupModal(pop_Id, true, ImGui.WindowFlags({})) then 
			local size_x, size_y = ImGui.GetContentRegionAvail()
			editor.style.draw_text_center("Tag列表")
			ImGui.BeginChild("detail", size_x, size_y - 80, ImGui.ChildFlags({"Border"}))
				for i, v in ipairs(data_hander.data.children) do 
					draw_item(v, 1, size_x)
				end
			ImGui.EndChild()
			ImGui.Dummy(10, 1)
			ImGui.Dummy(10, 10)
			ImGui.SameLineEx(size_x * 0.5 - 35)
			if editor.style.draw_btn("确 认##btn_ok", true, {size_x = 80}) then 
				params.callback(data_hander.get_all_selected() or {})
				ImGui.CloseCurrentPopup()
			end
			ImGui.EndPopup()
		end		
	end

	return api
end

return {new = new}