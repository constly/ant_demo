local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_01_system",
    category        = mgr.type_imgui,
    name            = "01_实时输入显示",
    desc            = "由于目前无法输入多行，所以该功能待定",
    file            = "imgui/imgui_01.lua"
}
local system = mgr.create_system(tbParam)
local ImGui = import_package "ant.imgui"

local default_input = 
[[
local ImGui = import_package "ant.imgui"
ImGui.Text("demo1")
]]

local input_context = {
    text = default_input,
    hint = "输入指令",
    width = 400,
    height = 400,
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
    ImGui.SetNextWindowSize(1000, 500)
    if ImGui.Begin("demo_imgui", ImGui.Flags.Window {"NoMove", "NoTitleBar"}) then 
        
        local bodyX = 10;
        local sizeX, sizeY = ImGui.GetContentRegionAvail()
        local childX = sizeX * 0.5 - bodyX * 3
        local childY = sizeY - 50

        --if ImGuiIO.KeyCtrl then 
        --    debug = not debug
        --end
        ImGui.Text("由于没搞定多行输入，所以先暂缓")

        --ImGui.SetCursorPos(bodyX, 20)
        ImGui.BeginChild("###child_input", childX, childY, ImGui.Flags.Child { "None" })
            --ImGui.Text("输入" .. sizeX .. ", " .. sizeY)
            ImGui.SetNextItemWidth(350)
            if ImGui.InputText("###input_1", input_context) then
               -- print(tostring(text.text))
            end
        ImGui.EndChild()

        ImGui.SameLine(childX + bodyX * 1.5)
        ImGui.BeginChild("###child_output", childX, childY)
            xpcall(function()
                load(tostring(input_context.text))()
            end, function(err)
                print(err)
            end)
        ImGui.EndChild()

    end
    ImGui.End()
end
