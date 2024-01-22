local ecs = ...
local m = ecs.system "demo_main_system"

local ImGui = import_package "ant.imgui"
local main  = require "main"
local category = nil
local selected = {}

local set_btn_style = function(current)
    if current then 
        ImGui.PushStyleColor(ImGui.Enum.Col.Button, 0.6, 0.6, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonHovered, 0.5, 0.5, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonActive, 0.5, 0.5, 0.25, 1)
    else 
        ImGui.PushStyleColor(ImGui.Enum.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonHovered, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonActive, 0.2, 0.2, 0.25, 1)
    end
end

function m:data_changed()
    -- 顶部菜单
    ImGui.SetNextWindowPos(169, 5)
    ImGui.SetNextWindowSize(1000, 40)
    if ImGui.Begin("demo_main_title", ImGui.Flags.Window {"AlwaysAutoResize", "NoMove", "NoTitleBar", "NoScrollbar"}) then 
        for i, v in ipairs(main.get_data()) do 
            local current = v.category == category
            set_btn_style(current)
            local label = v.category .. "###main_category_i_" .. i
            if ImGui.Button(label, 80, 25) or not category then 
                category = v.category
                if selected[category] then 
                    main.set_current_item(selected[category])
                end
            end
            ImGui.SameLine()
            ImGui.PopStyleColor(3)
        end
    end
    ImGui.End()

    local tbList = main.find_category(category) or {items = {}}
    local item
    
    -- 左边菜单
    ImGui.SetNextWindowPos(20, 45)
    ImGui.SetNextWindowSize(150, 600)
    ImGui.PushStyleVar(ImGui.Enum.StyleVar.ButtonTextAlign, 0, 0.5)
    if ImGui.Begin("demo_main_body_left", ImGui.Flags.Window {"AlwaysAutoResize", "NoMove", "NoTitleBar", "NoScrollbar"}) then 
        for i, v in ipairs(tbList.items) do 
            local label = v.name .. "###main_body_left_" .. i
            local current = v == selected[category]
            if current then 
                item = v
            end
            set_btn_style(current)
            if ImGui.Button(label, 135, 23) or not selected[category] then 
                selected[category] = v
                main.set_current_item(v)
            end
            ImGui.PopStyleColor(3)
        end
    end
    ImGui.End()
    ImGui.PopStyleVar()

    -- 功能描述
    ImGui.SetNextWindowPos(180, 50)
    ImGui.SetNextWindowSize(800, 100)
    if ImGui.Begin("demo_main_body_desc", ImGui.Flags.Window {"AlwaysAutoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBringToFrontOnFocus", "NoBackground"}) then 
        if item then 
            ImGui.Text(item.desc)
        end
    end
    ImGui.End()

end