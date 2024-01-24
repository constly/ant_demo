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

local start_x = 50
local headlen = 100 + start_x;
local start_x_2 = 500
local headlen2 = start_x_2 + 100
local line_space_y = 10
local tbDataList = {}

-- 当进入示例时
function system.on_entry()
    if not icon_btn then 
        icon_btn = assetmgr.resource("/pkg/game.res/images/btn_red.texture", { compile = true })
        tools.lib.dump(icon_btn)
    end
end

local draw_line = function(head1, body1, head2, body2)
    ImGui.Text(head1)
    ImGui.SameLine(headlen)
    body1()

    if head2 and body2 then
        ImGui.SameLine(start_x_2)
        ImGui.Text(head2)
        ImGui.SameLine(headlen2)
        body2()
    end
end

function system.data_changed()
    local start = mgr.get_content_start()
    ImGui.SetNextWindowPos(start.x, start.y)            
    ImGui.SetNextWindowSize(1000, 500)
    if ImGui.Begin("wnd_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBringToFrontOnFocus", "NoBackground"}) then 
        local n = math.ceil(#tbDataList / 2)
        for i = 1, n do 
            if i > 1 then 
                ImGui.Dummy(1, line_space_y)
                ImGui.NewLine()
            end
            ImGui.SameLine(start_x)
            local data1 = tbDataList[i * 2 - 1]
            local data2 = tbDataList[i * 2] or {}
            draw_line(data1[1], data1[2], data2[1], data2[2])
            ImGui.Separator()
        end
    end
    ImGui.End()
end

local tbComboList = {"峨眉山", "青城山", "西岭雪山", "稻城亚丁", "都江堰(感觉买门票不划算)"}
local cur_combo = tbComboList[1]
local cur_list_box = 1
local radio_flag = 1
local progress_value = 0.01

local drag_int_value = { [1] = 50, min = 0, max = 120, format = "%d%%" }
local drag_float_value = { [1] = 0.5, min = 0, max = 10, speed = 0.1, format = "%d%%" }
local slider_int_value = { [1] = 20, min = 0, max = 100 }
local slider_float_value = { [1] = 0.625, min = 0, max = 1 }
local list_box_value = { [1] = "AA", [2] = "BB", [3] = "CC", current = 1, height = 3 }

function system.init_world()
    local register = function(label, func)
        table.insert(tbDataList, {label, func})
    end
    register("Button:", function()
        if ImGui.Button("按钮##btn_1", 60, 23) then     
            flag[1] = not flag[1]
        end
        if flag[1] then 
            ImGui.SameLine()                            
            ImGui.Text("我被你点中咯")
        end
    end)
    register("RadioButton:", function()
        if ImGui.RadioButton("男生##radio_id_1", radio_flag == 1) then 
            radio_flag = 1
        end
        ImGui.SameLine()
        if ImGui.RadioButton("女生##radio_id_2", radio_flag == 2) then 
            radio_flag = 2
        end
    end)
    register("ImageButton:", function()
        if ImGui.ImageButton("##btn_2",  textureman.texture_get(icon_btn.id), 60, 23) then 
            flag[2] = not flag[2]
        end
        if flag[2] then 
            ImGui.SameLine(); 
            ImGui.Text("我被你点中咯") 
        end
    end)
    register("Image:", function()
        ImGui.Image(textureman.texture_get(icon_btn.id), 35, 35)
        if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
            ImGui.Text("你看这个饼，它又大又圆。")
            ImGui.EndTooltip()
        end
    end)
    register("InputText:", function()
        ImGui.SetNextItemWidth(150)
        if ImGui.InputText("##input_3", input_content) then 
            print("输入", input_content.text)
        end
        if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
            ImGui.Text(tostring(input_content.text))
            ImGui.EndTooltip()
        end
    end)
    register("Combo:", function()
        ImGui.SetNextItemWidth(150)
        if ImGui.BeginCombo("##combo_4", cur_combo) then
            for i, name in ipairs(tbComboList) do
                if ImGui.Selectable(name, name == cur_combo) then
                    cur_combo = name
                end
                if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
                    ImGui.TextWrapped(name .. "的描述", (i - 1) * 40 + 10)
                    ImGui.EndTooltip()
                end
            end
            ImGui.EndCombo()
        end
    end)
    register("DragInt:", function()
        ImGui.SetNextItemWidth(150)
        if ImGui.DragInt("##drag_int_1", drag_int_value) then
            print("drag int" .. drag_int_value[1])
        end
    end)
    register("DragFloat:", function()
        ImGui.SetNextItemWidth(150)
        if ImGui.DragFloat("##drag_float_11", drag_float_value) then
            print("drag float", drag_float_value[1])
        end
    end)
    register("SliderInt:", function()
        ImGui.SetNextItemWidth(150)
        ImGui.SliderInt("##slider_line_0501", slider_int_value)
    end)
    register("SliderFloat:", function()
        ImGui.SetNextItemWidth(150)
        ImGui.SliderFloat("##slider_line_0502", slider_float_value)
    end)
    register("帮助:", function()
        ImGui.TextDisabled("(?)");
        if ImGui.IsItemHovered() and ImGui.BeginTooltip() then 
            ImGui.PushTextWrapPos(16 * 35);
            ImGui.Text("黄河远上白云间，一片孤城万仞山。\n羌笛何须怨杨柳，春风不度玉门关。");
            ImGui.PopTextWrapPos();
            ImGui.EndTooltip();
        end
    end)
    register("ProgressBar:", function()
        progress_value = progress_value + 0.01
        if progress_value > 1 then 
            progress_value = 0 
        end
        ImGui.ProgressBar(progress_value, 150, 22, "嘿嘿") 
    end)
    register("ListBox:", function()
        ImGui.SetNextItemWidth(150)
        if ImGui.ListBox("##listbox", list_box_value) then 
            print("list is", list_box_value.current)
        end
    end)
    register("BeginListBox:", function()
        if ImGui.BeginListBox("##begin_list_box", 150, 70) then 
            for i, name in ipairs(tbComboList) do 
                if ImGui.Selectable(name, i == cur_list_box) then 
                    cur_list_box = i
                end
                if i == cur_list_box then 
                    ImGui.SetItemDefaultFocus();
                end
                if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
                    ImGui.Text(name)
                    ImGui.EndTooltip()
                end
            end
            ImGui.EndListBox()
        end
    end)
end
