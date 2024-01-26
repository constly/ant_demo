local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_01_system",
    category        = mgr.type_imgui,
    name            = "01_实时输入显示",
    desc            = "实时输入，实时绘制",
    file            = "imgui/imgui_01.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)
local ImGui = import_package "ant.imgui"
local tools = import_package 'game.tools'
local err_text = ""
local default_inputs
local cur_page = tools.user_data.get_number("imgui_01_page", 1)
local input_context = {
    text = "",
    hint = "输入指令",
    width = 400,
    height = 400,
    flags = ImGui.Flags.InputText{"CallbackCompletion", "CallbackHistory", "AllowTabInput"},
}

local set_btn_style = function(current)
    if current then 
        ImGui.PushStyleColor(ImGui.Enum.Col.Button, 0, 0.5, 0.8, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonHovered, 0, 0.55, 0.7, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonActive, 0, 0.55, 0.7, 1)
    else 
        ImGui.PushStyleColor(ImGui.Enum.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
    end
end

function system.data_changed()
    ImGui.SetNextWindowPos(200, 80)
    ImGui.SetNextWindowSize(970, 565)
    if ImGui.Begin("demo_imgui", ImGui.Flags.Window {"NoMove", "NoTitleBar", "NoResize"}) then 
		for i = 1, #default_inputs do 
			set_btn_style(i == cur_page)
			local label = string.format("P%d##btn_page_%d", i, i)
			if ImGui.Button(label, 50, 23) then 
				cur_page = i
				input_context.text = default_inputs[i]
				tools.user_data.set("imgui_01_page", tostring(i), true)
			end
			ImGui.SameLine()
			ImGui.PopStyleColor(3)
		end
		ImGui.NewLine()

		local bodyX = 10;
        local sizeX, sizeY = ImGui.GetContentRegionAvail()
        local childX = sizeX * 0.5 - bodyX * 3
        local childY = sizeY - 100
		if ImGui.InputTextMultiline("##input_2", input_context) then 
			default_inputs[cur_page] = tostring(input_context.text)
		end

        ImGui.SameLine(childX + bodyX * 1.5)
        ImGui.BeginChild("###child_output", childX, childY)
			err_text = ""
            xpcall(function()
                load(tostring(input_context.text))()
            end, function(err)
				err_text = err
            end)
        ImGui.EndChild()

		ImGui.SetCursorPos(10, sizeY - 60)
		ImGui.PushTextWrapPos(850);
        ImGui.Text(err_text)
		ImGui.PopTextWrapPos()
    end
    ImGui.End()
end


default_inputs = {
[1] = 
[[
local ImGui = import_package "ant.imgui"
ImGui.Text("text")
ImGui.Button("button")
ImGui.RadioButton("button")
]],

[2] = [[]],
[3] = [[]],
[4] = [[]],
[5] = [[]],
[6] = [[]],
[7] = [[]],
}

input_context.text = default_inputs[cur_page]