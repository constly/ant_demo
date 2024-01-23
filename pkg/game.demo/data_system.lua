local ecs = ...
local system = ecs.system "data_system"
local window = require "window"
local tools = import_package 'game.tools'
local ImGui = import_package "ant.imgui"
local data_mgr  = require "data_mgr"
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

function system:init_world()
    window.set_title("Ant Game Engine 使用大全")
    category = tools.user_data.get("last_category")
    if category ~= "" then 
        selected[category] = tools.user_data.get_number('last_category_' .. category)
        data_mgr.set_current_item(category, selected[category])    
    end
end

function system:data_changed()
    -- 顶部菜单
    ImGui.SetNextWindowPos(169, 5)
    ImGui.SetNextWindowSize(1000, 40)
    if ImGui.Begin("demo_main_title", ImGui.Flags.Window {"AlwaysAutoResize", "NoMove", "NoTitleBar", "NoScrollbar"}) then 
        for i, v in ipairs(data_mgr.get_data()) do 
            local current = v.category == category
            set_btn_style(current)
            local label = v.category .. "###main_category_i_" .. i
            if ImGui.Button(label, 80, 25) or category == "" then 
                category = v.category
                tools.user_data.set('last_category', category, true)
                if not selected[category] then 
                    selected[category] = tools.user_data.get_number('last_category_' .. category)
                end
                if selected[category] > 0 then 
                    data_mgr.set_current_item(category, selected[category])    
                end
            end
            ImGui.SameLine()
            ImGui.PopStyleColor(3)
        end
    end
    ImGui.End()

    local tbList = data_mgr.find_category(category) or {items = {}}
    local item
    
    -- 左边菜单
    ImGui.SetNextWindowPos(20, 44)
    ImGui.SetNextWindowSize(150, 600)
    ImGui.PushStyleVar(ImGui.Enum.StyleVar.ButtonTextAlign, 0, 0.5)
    if ImGui.Begin("demo_main_body_left", ImGui.Flags.Window {"AlwaysAutoResize", "NoMove", "NoTitleBar", "NoScrollbar"}) then 
        for i, v in ipairs(tbList.items) do 
            local label = v.name .. "###main_body_left_" .. i
            local current = v.id == selected[category]
            if current then 
                item = v
            end
            set_btn_style(current)
            if ImGui.Button(label, 135, 23) or not selected[category] or (selected[category] == 0) then 
                selected[category] = v.id
                data_mgr.set_current_item(category, v.id)
                -- 这里记录id不严谨，因为id是运行时动态生成的，不过影响不大，因为这是编辑器
                -- 99%的情况下这里不会出问题，即使出问题也是小问题
                tools.user_data.set('last_category_' .. category, v.id, true) 
            end
            ImGui.PopStyleColor(3)
        end
    end
    ImGui.End()
    ImGui.PopStyleVar()

    -- 功能描述
    if item and item.desc then 
        ImGui.SetNextWindowPos(180, 50)
        ImGui.SetNextWindowSize(800, 100)
        if ImGui.Begin("demo_main_body_desc", ImGui.Flags.Window {"NoInputs", "NoMove", "NoTitleBar", "NoScrollbar", "NoBringToFrontOnFocus", "NoBackground"}) then 
            ImGui.Text(item.desc)
        end
        ImGui.End()
    end

end