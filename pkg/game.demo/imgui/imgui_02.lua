local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_02_system",
    category        = mgr.type_imgui,
    name            = "02_基础控件",
    desc            = "展示ImGui常用基础控件",
    file            = "imgui/imgui_02.lua"
}
local system = mgr.create_system(tbParam)

local assetmgr  = import_package "ant.asset"
local ImGui = import_package "ant.imgui"
local tools = import_package "game.tools"
local textureman = require "textureman.client"
local input_content = {text = 'input'}

local flag = {}
local icon_btn
local tbComboList = {"峨眉山", "青城山", "西岭雪山", "稻城亚丁", "都江堰(感觉买门票不划算)"}
local cur_combo = tbComboList[1]
local radio_flag = 1
local progress_value = 0.01

local start_x = 50
local headlen = 100 + start_x;
local start_x_2 = 500
local headlen2 = start_x_2 + 100
local line_space_y = 10

-- 当进入示例时
function system.on_entry()
    if not icon_btn then 
        icon_btn = assetmgr.resource("/pkg/game.res/images/btn_red.texture", { compile = true })
        tools.lib.dump(icon_btn)
    end
end

function system.data_changed()
    local start = mgr.get_content_start()
    ImGui.SetNextWindowPos(start.x, start.y)            
    ImGui.SetNextWindowSize(1000, 500)
    if ImGui.Begin("wnd_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBringToFrontOnFocus", "NoBackground"}) then 
        for i = 1, 4 do 
            if i > 1 then 
                ImGui.Dummy(1, line_space_y)
                ImGui.NewLine()
            end
            ImGui.SameLine(start_x)
            system['draw_line_' .. i]()
            ImGui.Separator()
        end
    end
    ImGui.End()
end

local draw_line = function(head1, body1, head2, body2)
    ImGui.Text(head1)
    ImGui.SameLine(headlen)
    body1()

    ImGui.SameLine(start_x_2)
    ImGui.Text(head2)
    ImGui.SameLine(headlen2)
    body2()
end

-- 第一行
function system.draw_line_1()
    local func1 = function()
        if ImGui.Button("按钮##btn_1", 60, 23) then     
            flag[1] = not flag[1]
        end
        if flag[1] then 
            ImGui.SameLine()                            
            ImGui.Text("我被你点中咯")
        end
    end 
    local func2 = function()
        if ImGui.RadioButton("男生##radio_id_1", radio_flag == 1) then 
            radio_flag = 1
        end
        ImGui.SameLine()
        if ImGui.RadioButton("女生##radio_id_2", radio_flag == 2) then 
            radio_flag = 2
        end
    end
    draw_line("默认按钮:", func1, "单选按钮:", func2)
end

-- 第二行
function system.draw_line_2()
    local func1 = function()
        if ImGui.ImageButton("##btn_2",  textureman.texture_get(icon_btn.id), 60, 23) then 
            flag[2] = not flag[2]
        end
        if flag[2] then 
            ImGui.SameLine(); 
            ImGui.Text("我被你点中咯") 
        end
    end 
    local func2 = function()
        progress_value = progress_value + 0.01
        if progress_value > 1 then 
            progress_value = 0 
        end
        ImGui.ProgressBar(progress_value, 120, 22, "嘿嘿") 
    end
    draw_line("图片按钮:", func1, "进度条:", func2)
end 

-- 第三行
local drag_int_value = {
    [1] = 50,
    min = 0,
    max = 120,
    format = "%d%%"
}
function system.draw_line_3()
    local func1 = function()
        ImGui.SetNextItemWidth(150)
        if ImGui.InputText("##input_3", input_content) then 
            print("输入", input_content.text)
        end
        if ImGui.IsItemHovered() then
            if ImGui.BeginTooltip() then
                ImGui.Text(tostring(input_content.text))
                ImGui.EndTooltip()
            end
        end
    end
    local func2 = function()
        ImGui.SameLine(headlen2)
        ImGui.SetNextItemWidth(150)
        if ImGui.DragInt("##drag_int_1", drag_int_value) then
            print("drag int" .. drag_int_value[1])
        end
    end
    draw_line("文本输入:", func1, "拖动Int:", func2)
end

-- 第四行
local drag_float_value = {
    [1] = 0.5,
    min = 0,
    max = 10,
    speed = 0.1,
    format = "%d%%"
}
function system.draw_line_4()
    local func1 = function()
        ImGui.SetNextItemWidth(150)
        if ImGui.BeginCombo("##combo_4", cur_combo) then
            for i, name in ipairs(tbComboList) do
                if ImGui.Selectable(name, name == cur_combo) then
                    cur_combo = name
                end
                if ImGui.IsItemHovered() then
                    if ImGui.BeginTooltip() then
                        ImGui.TextWrapped(name .. "的描述", (i - 1) * 40 + 10)
                        ImGui.EndTooltip()
                    end
                end
            end
            ImGui.EndCombo()
        end
    end
    local func2 = function()
        ImGui.SetNextItemWidth(150)
        if ImGui.DragFloat("##drag_float_11", drag_float_value) then
            print("drag float", drag_float_value[1])
        end
    end
    draw_line("下拉选择:", func1, "拖动Float:", func2)    
end 

-- 第五行
function system.draw_line_5()
end