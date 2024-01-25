local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tools = import_package 'game.tools'
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_03_system",
    category        = mgr.type_imgui,
    name            = "03_各种Flag",
    desc            = "展示控件各种Flag效果",
    file            = "imgui/imgui_03.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)

local all_selected = {}
local selected = {}
local wnd_size = {x = 400, y = 400}
local wnd_pos = {x = 100, y = 100}
local contents = {}
local pages = {"Window", "Child", "InputText", "Table", "TreeNode", "Combo", "TabBar", "TabItem"}
local cur_page = tools.user_data.get('imgui_03_save_key')

local all_flags = {}
local tb_flags = {}

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

function system.on_entry()
    local start = mgr.get_content_start()
    wnd_pos = {x = start.x + 50,  y = 130}
    wnd_size = {x = 400, y = 400}
    contents = {}
    for i = 1, 5 do 
        table.insert(contents, "我见青山多妩媚，料青山，见我应如是。" )
    end 
end

function system.data_changed()
    ImGui.SetNextWindowPos(250, 60)
    ImGui.SetNextWindowSize(800, 40)
    if ImGui.Begin("title", ImGui.Flags.Window {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBackground"}) then 
        for i, name in ipairs(pages) do 
            local current = name == cur_page
            set_btn_style(current)
            local label = name .. "###btn_title_" .. i
            if ImGui.Button(label, 80, 25) or not cur_page then 
                cur_page = name
                selected = all_selected[i] or {}
                all_selected[i] = selected
                tools.user_data.set('imgui_03_save_key', name, true)
            end
            ImGui.SameLine()
            ImGui.PopStyleColor(3)
        end
    end
    ImGui.End()

    tb_flags = all_flags[cur_page]
    system['Draw_' .. cur_page]()

    ImGui.SetNextWindowPos(720, 130)  
    ImGui.SetNextWindowSize(400, 400)
    if ImGui.Begin("wnd_flags", ImGui.Flags.Window {"NoResize", "NoMove", "NoTitleBar"}) then 
        for i, name in ipairs(tb_flags) do 
            if ImGui.RadioButton(name .. "##flag" .. i, selected[i] == true) then 
                selected[i] = not selected[i]
            end
        end
    end
    ImGui.End()

    ImGui.SetNextWindowPos(880, 540)  
    ImGui.SetNextWindowSize(100, 400)
    if ImGui.Begin("wnd_buttom", ImGui.Flags.Window {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBackground"}) then 
        set_btn_style(false)
        if ImGui.Button("清 空##btn_clear_flag", 80, 25) then 
            for i, v in pairs(selected) do 
                selected[i] = nil
            end
        end
        ImGui.PopStyleColor(3)
    end
    ImGui.End()
end

function system.get_styles()
    local ret = {}
    for i, name in ipairs(tb_flags) do 
        if selected[i] then 
            table.insert(ret, name)
        end
    end
    return ret
end

----------------------------------------------------------------
--- Window
----------------------------------------------------------------
all_flags["Window"] = {
    "NoTitleBar", 
    "NoResize", 
    "NoMove", 
    "NoScrollbar",
    "NoScrollWithMouse",
    "NoCollapse",
    "AlwaysAutoResize",
    "NoBackground",
    "NoSavedSettings",
    "NoMouseInputs",
    "MenuBar",
    "HorizontalScrollbar",
    "NoFocusOnAppearing",
    "NoBringToFrontOnFocus",
    "NoBringToFrontOnFocus",
    "AlwaysVerticalScrollbar",
    "AlwaysHorizontalScrollbar",
    --"AlwaysUseWindowPadding",  -- 引擎似乎没导出，使用会报错
    "NoNavInputs",
    "NoNavFocus",
    "UnsavedDocument",
    "NoNav",
    "NoDecoration",
    "NoInputs",
}
function system.Draw_Window()
    ImGui.SetNextWindowPos(wnd_pos.x, wnd_pos.y)  
    ImGui.SetNextWindowSize(wnd_size.x, wnd_size.y)
    if ImGui.Begin("ImGui.Begin##window_imgui_03", ImGui.Flags.Window(system.get_styles())) then 
        for i, desc in ipairs(contents) do 
            ImGui.Text(desc)
        end
    end
    wnd_size.x, wnd_size.y = ImGui.GetWindowSize()
    ImGui.End()
end

----------------------------------------------------------------
--- Child
----------------------------------------------------------------
all_flags["Child"] = {
    "Border",
    "AlwaysUseWindowPadding",
    "ResizeX",
    "ResizeY",
    "AutoResizeX",
    "AutoResizeY",
    "AlwaysAutoResize",
    "FrameStyle",
}
function system.Draw_Child()
    ImGui.SetNextWindowPos(wnd_pos.x, wnd_pos.y)  
    ImGui.SetNextWindowSize(wnd_size.x, wnd_size.y)
    if ImGui.Begin("ChildParent##window_imgui_03_2", ImGui.Flags.Window {}) then 
        ImGui.SetCursorPos(50, 50)
        ImGui.BeginChild("ImGui.BeginChild", 300, 300, ImGui.Flags.Child(system.get_styles()), ImGui.Flags.Window { "HorizontalScrollbar" })
        for i, desc in ipairs(contents) do 
            ImGui.Text(desc)
        end
        ImGui.EndChild()
    end 
    ImGui.End()
end

----------------------------------------------------------------
--- InputText
----------------------------------------------------------------
all_flags["InputText"] = {

}
function system.Draw_InputText()
end

----------------------------------------------------------------
--- Table
----------------------------------------------------------------
all_flags["Table"] = {

}
function system.Draw_Table()
end

----------------------------------------------------------------
--- TreeNode
----------------------------------------------------------------
all_flags["TreeNode"] = {

}
function system.Draw_TreeNode()
end

----------------------------------------------------------------
--- Combo
----------------------------------------------------------------
all_flags["Combo"] = {

}
function system.Draw_Combo()
end


----------------------------------------------------------------
--- TabBar
----------------------------------------------------------------
all_flags["TabBar"] = {

}
function system.Draw_TabBar()
end

----------------------------------------------------------------
--- TabBar
----------------------------------------------------------------
all_flags["TabItem"] = {

}
function system.Draw_TabItem()
end
