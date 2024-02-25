local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_01_system",
    category        = mgr.type_imgui,
    name            = "01_实时绘制",
    desc            = "实时输入，实时绘制",
    file            = "imgui/imgui_01.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)
local ImGui     = require "imgui"
local ImGuiExtend = require "imgui.extend"
local dep = require 'dep'

local err_text = ""
local default_inputs
local text_editor
local cur_page = dep.common.user_data.get_number("imgui_01_page", 1)

local set_btn_style = function(current)
    if current then 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0, 0.5, 0.8, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0, 0.55, 0.7, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0, 0.55, 0.7, 1)
    else 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
    end
end

function system.on_entry()
	if not text_editor then 
		text_editor = ImGuiExtend.CreateTextEditor()
		text_editor:SetTabSize(8)
		text_editor:SetShowWhitespaces(false)
		text_editor:SetText(default_inputs[cur_page])
	end
end

function system.data_changed()
    ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("demo_imgui", nil, ImGui.WindowFlags {"NoMove", "NoTitleBar", "NoResize"}) then 
		for i = 1, #default_inputs do 
			set_btn_style(i == cur_page)
			local label = string.format("P%d##btn_page_%d", i, i)
			if ImGui.ButtonEx(label, 60) then 
				cur_page = i
				text_editor:SetText(default_inputs[i])
				dep.common.user_data.set("imgui_01_page", tostring(i), true)
			end
			ImGui.SameLine()
			ImGui.PopStyleColorEx(3)
		end
		ImGui.NewLine()

		local sizeX, sizeY = ImGui.GetContentRegionAvail()
        local half = sizeX * 0.5
        local childY = sizeY - 100

		text_editor:Render("##text_input", 500, 500, true)
		local str = text_editor:GetText()
		default_inputs[cur_page] = str

        ImGui.SameLine(half + 10)
        ImGui.BeginChild("###child_output", half - 30, childY)
			err_text = ""
            xpcall(function()
                load(tostring(str))()
            end, function(err)
				err_text = err
            end)
        ImGui.EndChild()

		ImGui.SetCursorPos(10, sizeY - 60)
		ImGui.PushTextWrapPos(sizeX - 100);
        ImGui.Text(err_text)
		ImGui.PopTextWrapPos()
    end
    ImGui.End()
end


default_inputs = {
[1] = 
[[
local ImGui     = require "imgui"
ImGui.Text("text")
ImGui.Button("button")
ImGui.RadioButton("button")
]],

[2] = [[local ImGui     = require "imgui"]],
[3] = [[]],
[4] = [[]],
[5] = [[]],
[6] = [[]],
[7] = [[]],
}
