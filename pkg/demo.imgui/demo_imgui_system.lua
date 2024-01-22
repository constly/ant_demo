local ecs = ...
local world = ecs.world
local w = world.w

local ImGui = import_package "ant.imgui"
local ImGuiIO = ImGui.io
local math3d = require "math3d"
local main = import_package "demo.main"
local m = ecs.system "main_system"


local demo1 = 
[[
    local ImGui = import_package "ant.imgui"
    ImGui.Text("demo1")
]]

local text = {text = demo1, hint = "测试"}

local id = main.register(m, "ImGui", {
    name = "实时显示",
    desc = "由于目前无法输入多行，所以该功能待定",
})

function m:data_changed()
    if id ~= main.get_current_id() then return end 

    ImGui.SetNextWindowPos(200, 95)
    ImGui.SetNextWindowSize(800, 500)
    if ImGui.Begin("demo_imgui", ImGui.Flags.Window {"NoMove", "NoTitleBar"}) then 
        
        local bodyX = 50;
        local sizeX, sizeY = ImGui.GetContentRegionAvail()
        local childX = sizeX * 0.5 - bodyX * 3
        local childY = sizeY - 50

        --if ImGuiIO.KeyCtrl then 
        --    debug = not debug
        --end

        ImGui.SetCursorPos(bodyX, 20)
        ImGui.BeginChild("###child_input", childX, childY, ImGui.Flags.Child { "None" })
            ImGui.Text("输入" .. sizeX .. ", " .. sizeY)
            if ImGui.InputText("###input.", text) then
               -- print(tostring(text.text))
            end
        ImGui.EndChild()

        ImGui.SameLine(childX + bodyX * 1.5)
        ImGui.BeginChild("###child_output", childX, childY)
            xpcall(function()
                load(tostring(text.text))()
            end, function(err)
                print(err)
            end)
        ImGui.EndChild()

    end
    ImGui.End()
end
