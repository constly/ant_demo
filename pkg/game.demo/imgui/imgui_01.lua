local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_01_system",
    category        = mgr.type_imgui,
    name            = "01_实时输入显示",
    desc            = "由于目前无法输入多行，所以该功能待定",
    file            = "imgui/imgui_01.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)
local ImGui = import_package "ant.imgui"
local err_text = ""
local default_input = 
[[
local ImGui = import_package "ant.imgui"
ImGui.Text("demo1")
]]

local input_context = {
    text = default_input,
    hint = "输入指令",
    width = 400,
    height = 450,
    flags = ImGui.Flags.InputText{"EnterReturnsTrue", "CallbackCompletion", "CallbackHistory", "AllowTabInput"},
    up = function()
        print("on pointer up")
    end,
    down = function()
        print("on pointer down")
    end
}

function system.data_changed()
    ImGui.SetNextWindowPos(200, 95)
    ImGui.SetNextWindowSize(1000, 600)
    if ImGui.Begin("demo_imgui", ImGui.Flags.Window {"NoMove", "NoTitleBar", "NoResize"}) then 
        local bodyX = 10;
        local sizeX, sizeY = ImGui.GetContentRegionAvail()
        local childX = sizeX * 0.5 - bodyX * 3
        local childY = sizeY - 100
        --if ImGuiIO.KeyCtrl then 
        --    debug = not debug
        --end
        ImGui.BeginChild("###child_input", childX, childY, ImGui.Flags.Child { "None" })
            if ImGui.InputTextMultiline("###input_1", input_context) then
            end
        ImGui.EndChild()

        ImGui.SameLine(childX + bodyX * 1.5)
        ImGui.BeginChild("###child_output", childX, childY)
			err_text = ""
            xpcall(function()
                load(tostring(input_context.text))()
            end, function(err)
                print(err)
				err_text = err
            end)
        ImGui.EndChild()

		ImGui.SetCursorPos(10, sizeY - 100)
		ImGui.PushTextWrapPos(850);
        ImGui.Text(err_text)
		ImGui.PopTextWrapPos()
    end
    ImGui.End()
end
