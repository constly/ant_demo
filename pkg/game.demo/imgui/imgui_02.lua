local ecs = ...
local mgr = require "data_mgr"
local system = mgr.create_system(ecs, "imgui_02_system", mgr.type_imgui, "02_基础控件", "展示ImGui常用基础控件")
local assetmgr  = import_package "ant.asset"
local ImGui = import_package "ant.imgui"
local tools = import_package "game.tools"
local textureman = require "textureman.client"
local input_content = {text = ''}

local flag = {}
local icon_btn
local cur_combo

-- 当进入示例时
function system.on_entry()
    if not icon_btn then 
        icon_btn = assetmgr.resource("/pkg/game.res/images/btn_blue.texture", { compile = true })
        tools.lib.dump(icon_btn)
    end
end

function system.data_changed()
    local headlen = 120;
    local start = mgr.get_content_start()
    ImGui.SetNextWindowPos(start.x, start.y)            -- 设置下个窗口位置 和 宽高
    ImGui.SetNextWindowSize(1000, 500)
    if ImGui.Begin("wnd_body", ImGui.Flags.Window {"NoMove", "NoTitleBar", "NoScrollbar", "NoBringToFrontOnFocus", "NoBackground"}) then 
        
        -- 第一行
        ImGui.Text("默认按钮")
        ImGui.SameLine(headlen)                             
        if ImGui.Button("按钮##btn_1", 60, 23) then     
            flag[1] = not flag[1]
        end
        if flag[1] then 
            ImGui.SameLine()                            
            ImGui.Text("我被你点中咯")
        end

        -- 第二行
        ImGui.Dummy(1, 15)                              
        ImGui.Text("图片按钮")
        ImGui.SameLine(headlen) 
        if ImGui.ImageButton("##btn_2",  textureman.texture_get(icon_btn.id), 60, 23) then 
            flag[2] = not flag[2]
        end
        if flag[2] then ImGui.SameLine(); ImGui.Text("我被你点中咯") end

        -- 第三行
        ImGui.Dummy(1, 15)                              
        ImGui.Text("文本输入")
        ImGui.SameLine(headlen) 
        ImGui.SetNextItemWidth(150)
        if ImGui.InputText("##input_3", input_content) then 
            print("输入", input_content.text)
        end
        ImGui.Text("输入内容")
        ImGui.SameLine(headlen) 
        ImGui.Text(tostring(input_content.text))

        -- 第四行
        ImGui.Dummy(1, 15)                              
        ImGui.Text("下拉选择")
        ImGui.SameLine(headlen) 
        ImGui.SetNextItemWidth(150)
        if ImGui.BeginCombo("##combo_4", cur_combo) then
            for i, name in ipairs({"峨眉山", "青城山", "西岭雪山", "都江堰", "蜀南竹海"}) do
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
    ImGui.End()
end
