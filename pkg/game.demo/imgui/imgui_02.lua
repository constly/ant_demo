local ecs = ...
local system = ecs.system "imgui_02_system"
local assetmgr  = import_package "ant.asset"
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local id = mgr.register(system, mgr.type_imgui, "02_基础控件", "展示ImGui常用基础控件")
local flag = {}
local icon_btn
local tools = import_package "game.tools"
local textureman = require "textureman.client"
local input_content = {text = ''}

function system:on_entry()
    if not icon_btn then 
        icon_btn = assetmgr.resource("/pkg/game.res/images/btn_blue.texture", { compile = true })
        tools.lib.dump(icon_btn)
    end
end

function system:data_changed()
    if id ~= mgr.get_current_id() then return end 

    local start = mgr.get_content_start()
    ImGui.SetNextWindowPos(start.x, start.y)            -- 设置下个窗口位置 和 宽高
    ImGui.SetNextWindowSize(1000, 500)
    if ImGui.Begin("wnd_body", ImGui.Flags.Window {"NoMove", "NoTitleBar", "NoScrollbar", "NoBringToFrontOnFocus", "NoBackground"}) then 
        
        -- 第一行
        ImGui.Text("默认按钮")
        ImGui.SameLine(120)                             -- 指定渲染位置位于本行开头120px处
        if ImGui.Button("按钮##btn_1", 60, 23) then     -- 按钮##btn_1 表示显示名字是"按钮"，id是"btn_1"；60,23是按钮的长度和高度
            flag[1] = not flag[1]
        end
        if flag[1] then 
            ImGui.SameLine()                            -- 这里没有加参数，表示接着本行继续渲染
            ImGui.Text("我被你点中咯")
        end

        -- 第二行
        ImGui.Dummy(1, 15)                              
        ImGui.Text("图片按钮")
        ImGui.SameLine(120) 
        if ImGui.ImageButton("##btn_2",  textureman.texture_get(icon_btn.id), 60, 23) then 
            flag[2] = not flag[2]
        end
        if flag[2] then ImGui.SameLine(); ImGui.Text("我被你点中咯") end

        -- 第三行
        ImGui.Dummy(1, 15)                              
        ImGui.Text("文本输入")
        ImGui.SameLine(120) 
        ImGui.SetNextItemWidth(150)
        if ImGui.InputText("##input_3", input_content) then 
            print("输入", input_content.text)
        end
        ImGui.Text("输入内容")
        ImGui.SameLine(120) 
        ImGui.Text(tostring(input_content.text))

    end
    ImGui.End()
end
